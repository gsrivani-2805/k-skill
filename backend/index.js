require("dotenv").config({ path: "./.env" });
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

// Define routes BEFORE starting server
const authRoutes = require("./routes/auth.route");
app.use("/api/auth", authRoutes);

const translateRoutes = require("./routes/translation.route");
app.use("/", translateRoutes);

const profileRoutes = require("./routes/profile.route");
app.use("/", profileRoutes);

const dictionaryRoutes = require("./routes/dictionary.route");
app.use("/", dictionaryRoutes);

const chatbotRouter = require("./routes/chat.route");
app.use("/", chatbotRouter);

// Example Route
app.get("/", (req, res) => {
  res.send("API is working");
});

// Start Server
console.log("MongoDB URI:", process.env.MONGO_URI); // Fixed variable name
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB connected");
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch((err) => console.error(err));