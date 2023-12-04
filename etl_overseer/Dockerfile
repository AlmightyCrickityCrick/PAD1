FROM elixir:latest


RUN apt-get update && \
    apt-get install -y build-essential && \
    mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

WORKDIR /app

COPY . /app
# Set environment variables (if needed)
# ENV MIX_ENV=prod

# Create and migrate the database (if applicable)

EXPOSE 7070

CMD ["/app/run_command.sh"]
