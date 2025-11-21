const jwt = require("jsonwebtoken");

module.exports = function (req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "Token manquant" });
  }

  const token = authHeader.split(" ")[1];
  if (!token) {
    return res.status(401).json({ message: "Format du token invalide" });
  }

  try {
    const decoded = jwt.verify(token, "secretKey123");

    
    req.user = decoded;

    next();
  } catch (err) {
    return res.status(401).json({ message: "Token invalide" });
  }
};
