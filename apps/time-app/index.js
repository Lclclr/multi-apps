const express = require("express");
const path = require("path");
const app = express();
const port = process.env.PORT || 8081;

app.use(express.static(path.join(__dirname, "public")));

app.get("/api/time", (req, res) => {
  res.json({ time: new Date().toString() });
});

app.listen(port, () => console.log(`Time app listening on port ${port}`));
