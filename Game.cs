using Godot;
using System;
using System.Collections.Generic;
using System.ComponentModel;

public partial class Game : Node2D
{
    public DodgeGame DodgeGameInstance { get; private set; } = new();
    private String initialText;
    private CharacterBody2D _robot;

    // Command dictionary now declared but not initialized here
    private Dictionary<string, Action<string>> _commands;

    public override void _Ready()
    {
        var textEditInit = GetNode<TextEdit>("IDE/TextEdit");
        this.initialText = textEditInit.Text;
        GD.Print("Game Scene Loaded");

        // Get Robot node
        _robot = GetNode<CharacterBody2D>("robot");

        // Initialize commands here (can use non-static methods now)
        _commands = new Dictionary<string, Action<string>>()
        {
            { "left", args => MoveRobot(Vector2.Left) },
            { "right", args => MoveRobot(Vector2.Right) },
            { "up", args => MoveRobot(Vector2.Up) },
            { "down", args => MoveRobot(Vector2.Down) },
        };

        // Setup TextEdit callback
        var textEdit = GetNode<TextEdit>("IDE/TextEdit");
        textEdit.TextChanged += OnTextChanged;
    }

    private void OnTextChanged()
    {
        var textEdit = GetNode<TextEdit>("IDE/TextEdit");
        var lines = textEdit.Text.Split("\n", StringSplitOptions.RemoveEmptyEntries);

        foreach (var line in lines)
        {
            var trimmed = line.Trim();
            var commandInd = trimmed.IndexOf("(");
            if (commandInd == -1) continue;

            var command = trimmed.Substring(0, commandInd);

            // Execute command if exists
            if (_commands.TryGetValue(command, out var action))
            {
                action(""); // currently no args
            }
            else
            {
                GD.Print("Not a valid command");
            }
        }
    }

    private void MoveRobot(Vector2 direction)
    {
        if (_robot == null)
        {
            GD.PrintErr("Robot node not found!");
            return;
        }

        _robot.Position += direction * 10;
        GD.Print($"Robot moved {direction}");
    }
}
