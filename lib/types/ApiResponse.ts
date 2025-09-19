/**
 * API统一响应格式
 */
export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
  code?: number;
}

/**
 * 分页参数
 */
export interface PaginationParams {
  page: number;
  limit: number;
}

/**
 * 分页结果
 */
export interface PaginationResult {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}