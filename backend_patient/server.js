const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const authRoutes = require("./routes/auth");
app.use("/api/auth", authRoutes);

app.listen(3000, () => console.log("Server running on port 3000"));

const appointmentsRoutes = require("./routes/appointments");
app.use("/api/appointments", appointmentsRoutes);

const historyRoutes = require("./routes/history");
app.use("/api/history", historyRoutes);

const notificationsRoutes = require("./routes/notifications");
app.use("/api/notifications", notificationsRoutes);

const doctorsRoutes = require('./routes/doctors');
app.use('/api/doctors', doctorsRoutes);