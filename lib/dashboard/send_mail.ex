defmodule Monitor.MyMail do
  import Swoosh.Email

  def welcome(user) do
    new()
    |> to({user.name, user.email})
    |> from({"Dr. Barnes", "jsmammen@gmail.com"})
    |> subject("Tesing email")
    |> html_body("<h1> hello #{user.name} </h1>")
    |> text_body("Hello #{user.name}\n")
    #|> Monitor.MyMailer.deliver()

  end

  def send(from_user, message, to_user) do
    new()
    |> to({to_user.name, to_user.email})
    |> from({from_user.name, from_user.email})
    |> subject("#{message.system} -- #{message.status}")
    |> html_body("<h2>#{message.system} has #{message.status} </h1>")
    |> text_body("#{message.system} has #{message.status}\n")
    end
end

# email = Monitor.MyMail.welcome(%{"name": "john", "email": "mammenj@live.com"})
# Monitor.MyMailer.deliver(email)
