package gmm_test

import (
	"amf/gmm"
	"free5gc/lib/fsm"
	"testing"
)

func TestGmmFSM(t *testing.T) {
	fsm.ExportDot(gmm.GmmFSM, "gmm")
}
