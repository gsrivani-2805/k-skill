const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { Resend } = require("resend");
const User = require("../models/user.model");

const resend = new Resend(process.env.RESEND_API_KEY);
const JWT_SECRET = process.env.JWT_SECRET || "kskill_super_secret_2025";
const otpStore = new Map();

function generateOTP() {
  return crypto.randomInt(100000, 999999).toString();
}

async function sendOTP(email, otp) {
  await resend.emails.send({
    from: "K-Skill <onboarding@resend.dev>", 
    to: email,
    subject: "OTP for K-Skill verification",
    text: `Your OTP code is ${otp}. It is valid for 5 minutes.`,
  });
}

router.post("/send-otp", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required." });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(404).json({ message: "Email already registered." });
    }

    const otp = generateOTP();
    otpStore.set(email, { otp, expires: Date.now() + 5 * 60 * 1000 }); // expires in 5 minutes

    await sendOTP(email, otp);

    res.status(200).json({ message: "OTP sent successfully." });
  } catch (error) {
    console.error("Resend error:", error);
    res.status(500).json({
      message: "Failed to send OTP.",
      error: error.message || "Unknown error",
    });
  }
});

router.post("/verify-otp", (req, res) => {
  const { email, otp } = req.body;

  const record = otpStore.get(email);
  if (!record) {
    return res.status(400).json({ success: false, message: "OTP not found." });
  }

  if (Date.now() > record.expires) {
    otpStore.delete(email);
    return res
      .status(400)
      .json({ success: false, message: "OTP has expired." });
  }

  if (record.otp !== otp) {
    return res
      .status(400)
      .json({ success: false, message: "Invalid OTP provided." });
  }

  otpStore.delete(email);
  res.status(200).json({ success: true, message: "Email verified successfully." });
});

router.post("/reset-password", async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res
        .status(400)
        .json({ message: "Email and new password are required." });
    }

    const updatedUser = await User.findOneAndUpdate(
      { email },
      {
        password: newPassword,
        otp: null,
        otpExpires: null,
      }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found." });
    }

    res.status(200).json({ message: "Password updated successfully." });
  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({ message: "Failed to reset password." });
  }
});

router.post("/signup", async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      class: userClass,
      gender,
      school,
      address,
    } = req.body;

    if (!email || !password || !name) {
      return res
        .status(400)
        .json({ message: "Name, email, and password are required." });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ message: "Email already registered." });

    const user = new User({
      name,
      email,
      password,
      class: userClass,
      gender,
      school,
      address,
      assessmentScores: {
        quiz: 0,
        reading: 0,
        listening: 0,
        overall: 0,
      },
    });

    await user.save();
    res.status(201).json({
      message: "User registered successfully.",
      userId: user._id,
    });
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: err.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password required." });
    }

    const user = await User.findOne({ email });
    if (!user || user.password !== password) {
      return res.status(400).json({ message: "Invalid email or password." });
    }

    const today = new Date();
    const lastLogin = user.lastLogin;

    if (lastLogin) {
      const last = new Date(lastLogin);
      const diffDays =
        (today.setHours(0, 0, 0, 0) - last.setHours(0, 0, 0, 0)) /
        (1000 * 60 * 60 * 24);

      if (diffDays === 1) {
        user.currentStreak += 1;
      } else if (diffDays > 1) {
        user.currentStreak = 1;
      }
    } else {
      user.currentStreak = 1;
    }

    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign(
      { userId: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      token,
      user: {
        userId: user._id,
        name: user.name,
        email: user.email,
        currentLevel: user.currentLevel,
        currentStreak: user.currentStreak,
      },
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
