using Arch.Core;
using Godot;
using System;

public partial class Robot : CharacterBody2D
{
    public Entity? RobotEntity { get; set; }
    private const int SPEED = 10;

    public override void _Ready()
    {
        // Called every time the node is added to the scene.
        // Initialization here.
        GD.Print("Hello from C# to Godot :)");
    }

    public override void _Process(double delta)
    {
        if (Input.IsActionPressed("ui_right"))
        {
            this.Position += new Vector2(SPEED, 0);
        }
        if (Input.IsActionPressed("ui_left"))
        {
            this.Position += new Vector2(-SPEED, 0);
        }
        if (Input.IsActionPressed("ui_down"))
        {
            this.Position += new Vector2(0, SPEED);
        }
        if (Input.IsActionPressed("ui_up"))
        {
            this.Position += new Vector2(0, -SPEED);
        }
    }
}
