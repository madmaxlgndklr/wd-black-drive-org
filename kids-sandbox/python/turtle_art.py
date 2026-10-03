import turtle

t = turtle.Turtle()
t.speed(0)
colors = ["red", "orange", "yellow", "green", "blue", "purple"]
for i in range(36):
    t.color(colors[i % len(colors)])
    t.circle(80)
    t.right(10)
turtle.done()
