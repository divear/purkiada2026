using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class Game : Node2D
{
    // Game instance
    public DodgeGame DodgeGameInstance { get; private set; } = new();

    // Robot node
    private CharacterBody2D? _robot;

    // Command dictionary: command -> async action
    private Dictionary<string, Func<float, Task>> _commands;

    // Current text lines
    private string[] currentText = Array.Empty<string>();

    // Optional Run button exported in inspector
    [Export] public Button? RunButton { get; set; }

    public override void _Ready()
    {
        GD.Print("Game Scene Loaded");

        // ------------------------------
        // RunButton setup
        // ------------------------------
        if (RunButton == null)
        {
            RunButton = GetNodeOrNull<Button>("RunButton");
        }

        if (RunButton != null)
            RunButton.Pressed += async () => await ExecuteCommandsSequentially();

        // ------------------------------
        // TextEdit setup
        // ------------------------------
        var textEdit = GetNodeOrNull<TextEdit>("IDE/TextEdit");
        if (textEdit != null)
        {
            textEdit.TextChanged += OnTextChanged;
            currentText = textEdit.Text.Split("\n", StringSplitOptions.RemoveEmptyEntries);
        }

        // ------------------------------
        // Robot setup
        // ------------------------------
        _robot = GetNodeOrNull<CharacterBody2D>("robot");
        if (_robot == null)
            GD.PrintErr("Robot node not found!");

        // ------------------------------
        // Initialize commands
        // ------------------------------
        _commands = new Dictionary<string, Func<float, Task>>()
        {
            { "left", step => MoveRobot(Vector2.Left, step) },
            { "right", step => MoveRobot(Vector2.Right, step) },
            { "up", step => MoveRobot(Vector2.Up, step) },
            { "down", step => MoveRobot(Vector2.Down, step) },
            { "sleep", async seconds => await Sleep(seconds) }
        };
    }

    private void OnTextChanged()
    {
        var textEdit = GetNodeOrNull<TextEdit>("IDE/TextEdit");
        if (textEdit != null)
            currentText = textEdit.Text.Split("\n", StringSplitOptions.RemoveEmptyEntries);
    }

    // ------------------------------
    // Execute all commands sequentially
    // ------------------------------
    private async Task ExecuteCommandsSequentially()
    {
        foreach (var line in currentText)
        {
            var trimmed = line.Trim();
            if (string.IsNullOrEmpty(trimmed)) continue;

            int open = trimmed.IndexOf("(");
            int close = trimmed.IndexOf(")");

            if (open == -1 || close == -1) continue;

            string command = trimmed.Substring(0, open).Trim().ToLower();
            string argStr = trimmed.Substring(open + 1, close - open - 1).Trim();

            float argValue = 0;
            if (!float.TryParse(argStr, out argValue))
            {
                argValue = command == "sleep" ? 1f : 50f; // default step size
            }

            if (_commands.TryGetValue(command, out var action))
            {
                await action(argValue); // sequentially await each command
            }
            else
            {
                GD.Print($"Unknown command: {command}");
            }
        }
    }

    // ------------------------------
    // Move the robot smoothly
    // ------------------------------
    private async Task MoveRobot(Vector2 direction, float stepSize)
    {
        if (_robot == null) return;

        int steps = 20; // divide movement into steps
        float movePerStep = stepSize / steps;
        float delayPerStep = 0.02f; // ~50 FPS

        for (int i = 0; i < steps; i++)
        {
            _robot.Position += direction * movePerStep;
            await ToSignal(GetTree().CreateTimer(delayPerStep), SceneTreeTimer.SignalName.Timeout);
        }

        GD.Print($"Robot moved {direction} by {stepSize}");
    }

    // ------------------------------
    // Sleep helper
    // ------------------------------
    private async Task Sleep(float seconds)
    {
        await ToSignal(GetTree().CreateTimer(seconds), SceneTreeTimer.SignalName.Timeout);
    }
}
