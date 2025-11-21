const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../db.js");

const router = express.Router();

// REGISTER
router.post("/register", async (req, res) => {
  try {
    const {
      nom,
      prenom,
      date_naissance,
      adresse,
      email,
      password,
      confirmPassword,
    } = req.body;

    
    console.log("REQ BODY:", req.body);
    if (
      !nom ||
      !prenom ||
      !date_naissance ||
      !adresse ||
      !email ||
      !password ||
      !confirmPassword
    ) {
      return res.status(400).json({ message: "Tous les champs sont obligatoires." });
    }

    
    if (password !== confirmPassword) {
      return res
        .status(400)
        .json({ message: "Les mots de passe ne correspondent pas." });
    }

   
    const existing = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: "Cet email est déjà utilisé." });
    }

    
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    
    await pool.query(
      `INSERT INTO users (nom, prenom, date_naissance, adresse, email, password_hash)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [nom, prenom, date_naissance, adresse, email, passwordHash]
    );

    return res.status(201).json({ message: "Compte créé avec succès." });
  } catch (err) {
    console.error("❌ ERREUR REGISTER :", err);
    res.status(500).json({ message: "Erreur serveur." });
  }
});

// LOGIN
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    
    if (!email || !password) {
      return res.status(400).json({ message: "Email et mot de passe obligatoires." });
    }

    
    const user = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

    if (user.rows.length === 0) {
      return res.status(400).json({ message: "Email ou mot de passe incorrect." });
    }

    const userData = user.rows[0];

    
    const isMatch = await bcrypt.compare(password, userData.password_hash);

    if (!isMatch) {
      return res.status(400).json({ message: "Email ou mot de passe incorrect." });
    }

   
    const token = jwt.sign(
      { id: userData.id, email: userData.email },
      "secretKey123",      
      { expiresIn: "7d" }
    );

    return res.json({
      message: "Connexion réussie.",
      token,
      user: {
        id: userData.id,
        nom: userData.nom,
        prenom: userData.prenom,
        email: userData.email
      }
    });

  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.status(500).json({ message: "Erreur serveur." });
  }
});
module.exports = router;
