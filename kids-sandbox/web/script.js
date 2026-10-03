let clicks = 0;
document.getElementById("btn").addEventListener("click", () => {
  clicks = clicks + 1;
  document.getElementById("count").textContent = "Clicks: " + clicks;
});
