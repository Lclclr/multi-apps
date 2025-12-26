const express = require("express");
const path = require("path");
const app = express();
const port = process.env.PORT || 8080;

app.use(express.static(path.join(__dirname, "public")));

app.get("/api/hello", (req, res) => {
  res.json({ message: "Hello, World!" });
});

app.listen(port, () => console.log(`Hello app listening on port ${port}`));
