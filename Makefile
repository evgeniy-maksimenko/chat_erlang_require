REBAR = `which rebar`
CONF = chat

all: deps compile

deps:
	@( $(REBAR) get-deps )

compile: clean
	@( $(REBAR) compile )

clean:
	@( $(REBAR) clean )

run:
	@( erl -boot start_sasl -config $(CONF) -pa ebin deps/*/ebin -s webserver )

.PHONY: all deps compile clean run