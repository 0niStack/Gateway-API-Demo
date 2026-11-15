.PHONY: install deploy test clean clean-all
install:   ; ./scripts/01-install-controller.sh
deploy:    ; ./scripts/02-deploy-demo.sh
test:      ; ./scripts/03-test.sh
clean:     ; ./scripts/99-cleanup.sh
clean-all: ; ./scripts/99-cleanup.sh --all
