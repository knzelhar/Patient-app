const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// GET
router.get('/my-doctors', auth, async (req, res) => {
  try {
    console.log(`📋 Récupération des médecins pour user ${req.user.id}`);

    const result = await pool.query(
      `SELECT 
        d.id,
        d.full_name,
        d.specialty,
        d.phone,
        d.email
       FROM doctors d
       INNER JOIN patient_doctors pd ON d.id = pd.doctor_id
       WHERE pd.user_id = $1
       ORDER BY d.full_name ASC`,
      [req.user.id]
    );

    console.log(`✅ ${result.rows.length} médecin(s) trouvé(s)`);

    res.json({
      success: true,
      data: result.rows
    });
  } catch (err) {
    console.error('❌ Erreur GET my-doctors:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur serveur',
      error: err.message 
    });
  }
});

// GET 
router.get('/family-doctor', auth, async (req, res) => {
  try {
    console.log(`👨‍⚕️ Récupération médecin de famille pour user ${req.user.id}`);

    
    const result = await pool.query(
      `SELECT 
        d.id,
        d.full_name,
        d.specialty,
        d.phone,
        d.email
       FROM doctors d
       INNER JOIN patient_doctors pd ON d.id = pd.doctor_id
       WHERE pd.user_id = $1
       ORDER BY pd.id ASC
       LIMIT 1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: true,
        data: null,
        message: 'Aucun médecin de famille assigné'
      });
    }

    console.log(`✅ Médecin de famille: ${result.rows[0].full_name}`);

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (err) {
    console.error('❌ Erreur GET family-doctor:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur serveur',
      error: err.message 
    });
  }
});

module.exports = router;