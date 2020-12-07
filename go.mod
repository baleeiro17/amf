module amf

go 1.14

require (
	free5gc v0.0.0
	github.com/antihax/optional v1.0.0
	github.com/antonfisher/nested-logrus-formatter v1.3.0
	github.com/gin-contrib/cors v1.3.1
	github.com/gin-gonic/gin v1.6.3
	github.com/google/uuid v1.1.2
	github.com/ishidawataru/sctp v0.0.0-20191218070446-00ab2ac2db07
	github.com/mitchellh/mapstructure v1.4.0
	github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
	github.com/sirupsen/logrus v1.7.0
	github.com/stretchr/testify v1.6.1
	github.com/urfave/cli v1.22.5
	gopkg.in/yaml.v2 v2.4.0
)

replace free5gc => ../free5gc
