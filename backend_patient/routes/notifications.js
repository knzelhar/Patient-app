const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

//GET
router.get('/', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, title, message, type, is_read, created_at, appointment_id
       FROM notifications
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 50`,
      [req.user.id]
    );

    
    const unreadCount = result.rows.filter(n => !n.is_read).length;

    console.log(`📊 User ${req.user.id}: ${result.rows.length} notifications, ${unreadCount} non lues`);

    res.json({
      success: true,
      data: result.rows,
      unread_count: unreadCount
    });
  } catch (err) {
    console.error('❌ Erreur GET notifications:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

//GET
router.get('/unread-count', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT COUNT(*) as count
       FROM notifications
       WHERE user_id = $1 AND is_read = FALSE`,
      [req.user.id]
    );

    res.json({
      success: true,
      count: parseInt(result.rows[0].count)
    });
  } catch (err) {
    console.error('❌ Erreur count notifications:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

//POST 
router.post('/:id/read', auth, async (req, res) => {
  try {
    console.log(`📌 POST /notifications/${req.params.id}/read - User: ${req.user.id}`);
    
    const result = await pool.query(
      `UPDATE notifications
       SET is_read = TRUE
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      console.log(`❌ Notification ${req.params.id} introuvable pour user ${req.user.id}`);
      return res.status(404).json({
        success: false,
        message: 'Notification introuvable'
      });
    }

    console.log(`✅ Notification ${req.params.id} marquée comme lue`);
    res.json({ 
      success: true, 
      message: 'Notification marquée comme lue',
      data: result.rows[0] 
    });
  } catch (err) {
    console.error('❌ Erreur POST mark as read:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

//PUT
router.put('/:id/read', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `UPDATE notifications
       SET is_read = TRUE
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notification introuvable'
      });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    console.error('❌ Erreur mark as read:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

// PUT 
router.put('/mark-all-read', auth, async (req, res) => {
  try {
    await pool.query(
      `UPDATE notifications
       SET is_read = TRUE
       WHERE user_id = $1 AND is_read = FALSE`,
      [req.user.id]
    );

    res.json({ success: true, message: 'Toutes les notifications marquées comme lues' });
  } catch (err) {
    console.error('❌ Erreur mark all as read:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

//DELETE
router.delete('/:id', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `DELETE FROM notifications
       WHERE id = $1 AND user_id = $2
       RETURNING id`,
      [req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notification introuvable'
      });
    }

    res.json({ success: true, message: 'Notification supprimée' });
  } catch (err) {
    console.error('❌ Erreur delete notification:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

// DELETE
router.delete('/clear-read', auth, async (req, res) => {
  try {
    await pool.query(
      `DELETE FROM notifications
       WHERE user_id = $1 AND is_read = TRUE`,
      [req.user.id]
    );

    res.json({ success: true, message: 'Notifications lues supprimées' });
  } catch (err) {
    console.error('❌ Erreur clear read:', err);
    res.status(500).json({ success: false, message: 'Erreur serveur' });
  }
});

module.exports = router;