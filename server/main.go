package main

import (
	"bytes"
	"fmt"
	"github.com/labstack/echo/v4"
	"net/http"
	"net/url"
	"os/exec"
	"path"
	"strings"
)

// 传入
func handle(ctx echo.Context) error {
	args := new(struct {
		Name string `query:"name"`
	})
	err := ctx.Bind(args)
	if err != nil {
		return ctx.JSON(http.StatusOK, map[string]interface{}{
			"code":    1,
			"message": "arg bind err",
		})
	}
	// 编码问题
	args.Name, _ = url.QueryUnescape(args.Name)
	name := path.Base(args.Name)
	name = strings.Replace(name, path.Ext(args.Name), "", -1)
	// 传入 wenku 一级分类 二级分类 文件名.后缀 文件名 5个参数
	bashArgs := append(strings.Split(args.Name, "/"), name)
	cmd := exec.Command("./parse.sh", bashArgs...)
	outErr := bytes.NewBuffer([]byte{})
	out := bytes.NewBuffer([]byte{})
	cmd.Stdout = out
	cmd.Stderr = outErr
	err = cmd.Run()
	if err != nil {
		return ctx.JSON(http.StatusOK, map[string]interface{}{
			"code":    1,
			"message": outErr.String() + "\n" + err.Error(),
		})
	}
	return ctx.JSON(http.StatusOK, map[string]interface{}{
		"code":    0,
		"message": out.String(),
	})
}

func main() {
	e := echo.New()
	e.GET("/2016-08-15/proxy/transformer.LATEST/office2image/parse", handle)
	if err := e.Start(":9000"); err != nil {
		fmt.Println("server start fail", err)
	}
}
