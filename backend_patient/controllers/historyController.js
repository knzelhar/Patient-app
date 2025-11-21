// controllers/historyController.js
const db = require('../db');


const getHistory = async (req, res) => {
  
  const userId = req.user?.id || req.params.userId;

  console.log('📋 getHistory appelé pour userId:', userId);

  try {
   
    const query = `
      SELECT 
        id, 
        doctor_name, 
        date_consultation, 
        motif, 
        notes, 
        created_at, 
        updated_at
      FROM consultations
      WHERE user_id = $1 AND date_consultation < NOW()
      ORDER BY date_consultation DESC
    `;

    console.log('🔍 Exécution de la requête pour userId:', userId);
    const { rows } = await db.query(query, [userId]);
    console.log('✅ Résultats trouvés:', rows.length);

    return res.status(200).json({
      status: 'success',
      data: rows,
    });
  } catch (err) {
    console.error('❌ Erreur getHistory:', err.message);
    console.error('❌ Stack:', err.stack);
    return res.status(500).json({
      status: 'error',
      message: 'Impossible de récupérer l\'historique',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

module.exports = { getHistory };