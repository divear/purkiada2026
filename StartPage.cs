using Godot;
using System;

public partial class StartPage : Control
{
    [Export]
    public Button? StartButton { get; set; }
    [Export]
    public Button? SettingsButton { get; set; }
    public override void _Ready()
  {
    ArgumentNullException.ThrowIfNull(this.StartButton);
    ArgumentNullException.ThrowIfNull(this.SettingsButton);
    this.StartButton.Pressed += () =>
    {
      var gameScene = GD.Load<PackedScene>("res://game.tscn").Instantiate<Game>();
      AddChild(gameScene);
      GD.Print("Start Page ");
    };
    this.SettingsButton.Pressed += () =>
    {
      GD.Print("nastaveni jsem jeste neudelal");
    };
    GD.Print("Start Page Loaded");
  }
}
