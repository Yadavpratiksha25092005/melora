package s3

import (
	"context"
	"fmt"
	"mime/multipart"
	"net/url"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type Client struct {
	minio      *minio.Client
	bucket     string
	publicHost string // e.g. "localhost:9000" — used to build public URLs
	scheme     string // "http" or "https" — matches useSSL, used for public URLs
}

func NewClient(endpoint, accessKey, secretKey, bucket string, useSSL bool) (*Client, error) {
	mc, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, err
	}

	ctx := context.Background()
	exists, err := mc.BucketExists(ctx, bucket)
	if err != nil {
		return nil, err
	}
	if !exists {
		if err := mc.MakeBucket(ctx, bucket, minio.MakeBucketOptions{}); err != nil {
			return nil, err
		}

	}

	scheme := "http"
	if useSSL {
		scheme = "https"
	}

	return &Client{minio: mc, bucket: bucket, publicHost: endpoint, scheme: scheme}, nil
}

func (c *Client) Upload(ctx context.Context, key string, file multipart.File, size int64, contentType string) (string, error) {
	_, err := c.minio.PutObject(ctx, c.bucket, key, file, size, minio.PutObjectOptions{
		ContentType: contentType,
	})
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("https://%s/%s/%s", c.publicHost, c.bucket, key), nil
}

func (c *Client) GetPresignedURL(ctx context.Context, key string, expiry time.Duration) (string, error) {
	reqParams := make(url.Values)
	presignedURL, err := c.minio.PresignedGetObject(ctx, c.bucket, key, expiry, reqParams)
	if err != nil {
		return "", err
	}
	return presignedURL.String(), nil
}
