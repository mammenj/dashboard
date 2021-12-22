defmodule Monitor do
  @moduledoc """
  Documentation for `Monitor`.
  """

  use Application
  def start(_type, _args) do
    children =[
      {Monitor.Supervisor, [name: Monitor.Supervisor]}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
