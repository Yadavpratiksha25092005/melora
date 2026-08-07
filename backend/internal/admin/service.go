package admin

import "context"

type Service interface {
	Dashboard(ctx context.Context) (DashboardResponse, error)
	ListUsers(ctx context.Context, limit, offset int) ([]UserResponse, error)
	DeleteUser(ctx context.Context, id string) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) Dashboard(ctx context.Context) (DashboardResponse, error) {
	return s.repo.Dashboard(ctx)
}

func (s *service) ListUsers(ctx context.Context, limit, offset int) ([]UserResponse, error) {
	return s.repo.ListUsers(ctx, limit, offset)
}

func (s *service) DeleteUser(ctx context.Context, id string) error {
	return s.repo.DeleteUser(ctx, id)
}
