const express = require("express");
const router = express.Router();
const pool = require("../db.js");
const auth = require("../middleware/auth.js");

// GET 
router.get("/", auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM appointments WHERE user_id = $1 ORDER BY appointment_at ASC`,
      [req.user.id]
    );

    res.json({ success: true, data: result.rows });
  } catch (err) {
    console.error("❌ ERREUR GET appointments:", err);
    res.status(500).json({ success: false, message: "Erreur serveur" });
  }
});

// POST
router.post("/", auth, async (req, res) => {
  const { title, description, doctor, location, appointment_at } = req.body;

  if (!title || !appointment_at) {
    return res
      .status(400)
      .json({ success: false, message: "Titre et date obligatoires" });
  }

  try {
    
    const appointmentResult = await pool.query(
      `INSERT INTO appointments (user_id, title, description, doctor, location, appointment_at)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [req.user.id, title, description, doctor, location, appointment_at]
    );

    const appointment = appointmentResult.rows[0];

    
    const dateFormatted = new Date(appointment_at).toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    await pool.query(
      `INSERT INTO notifications (user_id, type, title, message, is_read, related_id)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        req.user.id,
        'appointment_created',
        '✅ Rendez-vous créé',
        `Votre rendez-vous "${title}" avec ${doctor} est prévu le ${dateFormatted}`,
        false,
        appointment.id
      ]
    );

    console.log(`✅ RDV créé (ID: ${appointment.id}) et notification envoyée pour l'utilisateur ${req.user.id}`);
    res.json({ success: true, data: appointment });

  } catch (err) {
    console.error("❌ ERREUR POST appointment:", err);
    res.status(500).json({ success: false, message: "Erreur serveur" });
  }
});

//PUT 
router.put("/:id", auth, async (req, res) => {
  const { title, description, doctor, location, appointment_at, status } = req.body;

  try {
    
    const result = await pool.query(
      `UPDATE appointments
       SET title=$1, description=$2, doctor=$3, location=$4, appointment_at=$5, status=$6, updated_at=NOW()
       WHERE id=$7 AND user_id=$8
       RETURNING *`,
      [
        title,
        description,
        doctor,
        location,
        appointment_at,
        status,
        req.params.id,
        req.user.id,
      ]
    );

    if (result.rows.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Rendez-vous introuvable" });
    }

    const appointment = result.rows[0];

    
    const dateFormatted = new Date(appointment_at).toLocaleDateString('fr-FR', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    await pool.query(
      `INSERT INTO notifications (user_id, type, title, message, is_read, related_id)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        req.user.id,
        'appointment_updated',
        '📝 Rendez-vous modifié',
        `Votre rendez-vous "${title}" avec ${doctor} a été modifié. Nouvelle date : ${dateFormatted}`,
        false,
        appointment.id
      ]
    );

    console.log(`✅ RDV ${appointment.id} modifié et notification envoyée`);
    res.json({ success: true, data: appointment });

  } catch (err) {
    console.error("❌ ERREUR PUT appointment:", err);
    res.status(500).json({ success: false, message: "Erreur serveur" });
  }
});

// DELETE
router.delete("/:id", auth, async (req, res) => {
  try {
    
    const appointmentInfo = await pool.query(
      `SELECT title, doctor FROM appointments WHERE id=$1 AND user_id=$2`,
      [req.params.id, req.user.id]
    );

    if (appointmentInfo.rows.length === 0) {
      return res
        .status(404)
        .json({ success: false, message: "Rendez-vous introuvable" });
    }

    const { title, doctor } = appointmentInfo.rows[0];

   
    await pool.query(
      `DELETE FROM appointments WHERE id=$1 AND user_id=$2`,
      [req.params.id, req.user.id]
    );

   
    await pool.query(
      `INSERT INTO notifications (user_id, type, title, message, is_read)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        req.user.id,
        'appointment_cancelled',
        '❌ Rendez-vous annulé',
        `Votre rendez-vous "${title}" avec ${doctor} a été annulé`,
        false
      ]
    );

    console.log(`✅ RDV ${req.params.id} supprimé et notification envoyée`);
    res.json({ success: true, message: "Supprimé avec succès" });

  } catch (err) {
    console.error("❌ ERREUR DELETE appointment:", err);
    res.status(500).json({ success: false, message: "Erreur serveur" });
  }
});

module.exports = router;