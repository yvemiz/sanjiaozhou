<template>
  <view class="category-page tab-page">
    <view class="category-body">
      <!-- 左侧父级分类 -->
      <scroll-view scroll-y class="side" :show-scrollbar="false">
        <view
          v-for="c in parentCategories"
          :key="c.id"
          class="side-item"
          :class="{ active: selectedParentId === c.id }"
          @click="selectParent(c)"
        >
          <text class="side-text">{{ c.name }}</text>
        </view>
      </scroll-view>
      <!-- 右侧内容 -->
      <scroll-view scroll-y class="main" :show-scrollbar="false" @scrolltolower="loadMoreProducts">
        <!-- 子分类标签 -->
        <scroll-view scroll-x class="children-wrap" :show-scrollbar="false">
          <view class="children-inner">
            <view
              class="child-tag"
              :class="{ active: selectedChildId === 0 }"
              @click="selectChild(0)"
            >全部</view>
            <view
              v-for="child in currentChildren"
              :key="child.id"
              class="child-tag"
              :class="{ active: selectedChildId === child.id }"
              @click="selectChild(child.id)"
            >
              {{ child.name }}
            </view>
          </view>
        </scroll-view>
        <!-- 商品列表（横向卡片） -->
        <view class="product-section">
          <view
            v-for="p in products" :key="p.id"
            class="product-row"
            @click="goProductDetail(p.id)"
          >
            <view class="product-cover-box">
              <image v-if="p.coverImage" class="product-cover" :src="p.coverImage" mode="aspectFill" lazy-load />
              <view v-else class="product-tactical-thumb">
                <text class="thumb-icon">◈</text>
                <text class="thumb-tag">特战委托</text>
              </view>
            </view>
            <view class="product-info">
              <text class="product-name">{{ p.name }}</text>
              <text v-if="p.subtitle" class="product-subtitle">{{ p.subtitle }}</text>
              <view class="tag-row">
                <text class="tag-chip">纯手打</text>
                <text class="tag-chip sec">掉装包赔</text>
              </view>
              <view class="product-bottom">
                <text class="product-price">¥{{ Number(p.price || 0).toFixed(2) }}</text>
                <text class="order-btn">去预约</text>
              </view>
            </view>
          </view>
          <view v-if="productLoading" class="loading-tip">加载中...</view>
          <view v-if="!productLoading && products.length === 0" class="empty-tip">暂无特战商品</view>
          <view v-if="productFinished && products.length > 0" class="loading-tip">没有更多了</view>
        </view>
      </scroll-view>
    </view>
    <CustomTabBar :current="1" />
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import CustomTabBar from '@/components/CustomTabBar.vue'
import { getCategoryTree } from '@/api/category'
import { getProductList } from '@/api/product'
const categoryTree = ref([])
const selectedParentId = ref(0)
const selectedChildId = ref(0)
const loading = ref(false)

const products = ref([])
const productLoading = ref(false)
const productFinished = ref(false)
const productPageNum = ref(1)

const parentCategories = computed(() => categoryTree.value)

const currentChildren = computed(() => {
  const parent = categoryTree.value.find((c) => c.id === selectedParentId.value)
  return parent?.children || []
})

const queryCategoryId = computed(() => {
  if (selectedChildId.value) return selectedChildId.value
  return null
})

const queryParentCategoryId = computed(() => {
  if (!selectedChildId.value && selectedParentId.value) return selectedParentId.value
  return null
})

const inited = ref(false)

onShow(async () => {
  const storedId = uni.getStorageSync('selectedCategoryId')
  if (storedId) uni.removeStorageSync('selectedCategoryId')

  if (!inited.value) {
    loading.value = true
    try {
      const res = await getCategoryTree()
      const tree = res.data || []
      categoryTree.value = tree
      if (storedId) {
        applyStoredId(tree, Number(storedId))
      } else if (tree.length > 0) {
        selectedParentId.value = tree[0].id
      }
    } catch (e) {
      categoryTree.value = []
    }
    loading.value = false
    inited.value = true
    refreshProducts()
  } else if (storedId) {
    applyStoredId(categoryTree.value, Number(storedId))
    refreshProducts()
  }
})

function applyStoredId(tree, id) {
  const isParent = tree.some(c => c.id === id)
  if (isParent) {
    selectedParentId.value = id
    selectedChildId.value = 0
  } else {
    for (const p of tree) {
      const child = (p.children || []).find(c => c.id === id)
      if (child) {
        selectedParentId.value = p.id
        selectedChildId.value = child.id
        break
      }
    }
  }
}

function selectParent(c) {
  selectedParentId.value = c.id
  selectedChildId.value = 0
  refreshProducts()
}

function selectChild(childId) {
  selectedChildId.value = childId
  refreshProducts()
}

function refreshProducts() {
  productPageNum.value = 1
  products.value = []
  productFinished.value = false
  loadProducts()
}

async function loadProducts() {
  if (productLoading.value) return
  productLoading.value = true
  try {
    const params = { pageNum: productPageNum.value, pageSize: 10 }
    if (queryCategoryId.value) {
      params.categoryId = queryCategoryId.value
    } else if (queryParentCategoryId.value) {
      params.parentCategoryId = queryParentCategoryId.value
    }
    const res = await getProductList(params)
    const list = res.data?.records || res.data?.rows || []
    if (list.length < 10) productFinished.value = true
    products.value = productPageNum.value === 1 ? list : [...products.value, ...list]
  } catch (e) {
    products.value = productPageNum.value === 1 ? [] : products.value
  }
  productLoading.value = false
}

function goProductDetail(id) {
  uni.navigateTo({ url: `/pages/product/detail?id=${id}` })
}

function loadMoreProducts() {
  if (!productLoading.value && !productFinished.value) {
    productPageNum.value++
    loadProducts()
  }
}
</script>

<style lang="scss" scoped>
.category-page {
  height: 100vh;
  background: #f8fafc;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  padding-bottom: 0;
}

.category-body {
  position: absolute;
  top: 0;
  right: 0;
  bottom: calc(110rpx + env(safe-area-inset-bottom));
  left: 0;
  display: flex;
  overflow: hidden;
  z-index: 1;
}

.side {
  width: 200rpx;
  height: 100%;
  background: #ffffff;
  flex-shrink: 0;
  box-sizing: border-box;
  overflow: hidden;
}

.side-item {
  padding: 28rpx 16rpx;
  font-size: 26rpx;
  color: #64748b;
  text-align: center;
  position: relative;
  box-sizing: border-box;

  .side-text {
    display: block;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  &.active {
    background: #f1f5f9;
    color: #f59e0b;
    font-weight: 700;
    border-left: 6rpx solid #f59e0b;
  }
}

.main {
  flex: 1;
  min-width: 0;
  height: 100%;
  padding: 20rpx;
  box-sizing: border-box;
  overflow: hidden;
}

/* #ifdef H5 */
.side :deep(.uni-scroll-view::-webkit-scrollbar),
.side :deep(.uni-scroll-view-content::-webkit-scrollbar),
.main :deep(.uni-scroll-view::-webkit-scrollbar),
.main :deep(.uni-scroll-view-content::-webkit-scrollbar) {
  width: 0;
  height: 0;
  display: none;
}
/* #endif */

.children-wrap {
  white-space: nowrap;
  margin-bottom: 24rpx;
  height: 72rpx;
}

.children-inner {
  display: inline-flex;
  gap: 16rpx;
  padding-right: 20rpx;
}

.child-tag {
  display: inline-block;
  padding: 12rpx 24rpx;
  font-size: 24rpx;
  color: #64748b;
  background: #ffffff;
  border-radius: 999rpx;
  border: 1rpx solid #e2e8f0;
  white-space: nowrap;
  flex-shrink: 0;
  transition: all 0.2s ease;

  &.active {
    background: #0f172a;
    border-color: #0f172a;
    color: #fbbf24;
    font-weight: 600;
  }

  &:active {
    opacity: 0.8;
  }
}

.product-section {
  min-height: 200rpx;
  overflow: hidden;
}

.product-row {
  display: flex;
  gap: 20rpx;
  padding: 20rpx;
  background: #ffffff;
  border-radius: 16rpx;
  margin-bottom: 16rpx;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 4rpx 14rpx rgba(15, 23, 42, 0.04);
  overflow: hidden;
}

.product-cover-box {
  width: 170rpx;
  height: 170rpx;
  border-radius: 12rpx;
  flex-shrink: 0;
  overflow: hidden;
}

.product-cover {
  width: 100%;
  height: 100%;
}

.product-tactical-thumb {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #0f172a, #1e293b);
  border: 1rpx solid #334155;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;

  .thumb-icon {
    font-size: 38rpx;
    color: #f59e0b;
    text-shadow: 0 0 10rpx rgba(245, 158, 11, 0.5);
  }

  .thumb-tag {
    font-size: 20rpx;
    font-weight: 700;
    color: #94a3b8;
    letter-spacing: 1rpx;
  }
}

.product-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  overflow: hidden;
}

.product-name {
  font-size: 27rpx;
  color: #0f172a;
  font-weight: 700;
  line-height: 1.35;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.product-subtitle {
  font-size: 22rpx;
  color: #64748b;
  margin-top: 4rpx;
  display: block;
  width: 100%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.tag-row {
  display: flex;
  gap: 8rpx;
  margin: 8rpx 0;
  flex-wrap: wrap;

  .tag-chip {
    font-size: 19rpx;
    font-weight: 600;
    padding: 2rpx 10rpx;
    border-radius: 6rpx;
    background: rgba(16, 185, 129, 0.12);
    color: #059669;
    border: 1rpx solid rgba(16, 185, 129, 0.25);

    &.sec {
      background: rgba(245, 158, 11, 0.12);
      color: #d97706;
      border-color: rgba(245, 158, 11, 0.25);
    }
  }
}

.product-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.product-price {
  font-size: 32rpx;
  font-weight: 800;
  color: #b45309;
  letter-spacing: -0.5rpx;
}

.order-btn {
  padding: 8rpx 20rpx;
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: #ffffff;
  font-size: 22rpx;
  font-weight: 700;
  border-radius: 8rpx;
  box-shadow: 0 4rpx 10rpx rgba(217, 119, 6, 0.25);
}

.loading-tip {
  text-align: center;
  padding: 32rpx;
  font-size: 24rpx;
  color: #94a3b8;
}

.empty-tip {
  width: 100%;
  text-align: center;
  padding: 60rpx;
  font-size: 26rpx;
  color: #94a3b8;
}
</style>
