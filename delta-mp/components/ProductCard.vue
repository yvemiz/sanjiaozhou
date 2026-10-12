<template>
  <view class="product-card" :class="{ dense }" @click="goDetail">
    <!-- 封面图或战术战备封面卡片 -->
    <view class="cover-wrapper" :style="{ height: coverHeight + 'rpx' }">
      <image
        v-if="product.coverImage && !imgError"
        class="cover"
        :src="product.coverImage"
        mode="aspectFill"
        lazy-load
        @error="imgError = true"
      />
      <!-- 无封面或图片失效时的战术HUD卡面 -->
      <view v-else class="tactical-cover" :class="modeThemeClass">
        <view class="tactical-hud-grid" />
        <view class="tactical-badge">{{ modeTag }}</view>
        <view class="tactical-center-emblem">
          <text class="tactical-icon">◈</text>
          <text class="tactical-code">DELTA-OPS</text>
        </view>
        <view class="tactical-bottom-badge">
          <text class="badge-dot">●</text>
          <text class="badge-text">绿色纯手打 · 掉装包赔</text>
        </view>
      </view>
      <view v-if="product.isRecommend" class="recommend-chip">特战推荐</view>
    </view>

    <view class="info">
      <text class="name text-ellipsis-2">{{ product.name }}</text>
      <view v-if="product.subtitle" class="subtitle-wrap">
        <text class="subtitle text-ellipsis">{{ product.subtitle }}</text>
      </view>
      <view class="tag-row">
        <text class="tag-chip">保底撤离</text>
        <text class="tag-chip sec">假一赔十</text>
      </view>
      <view class="bottom">
        <view class="price-wrap">
          <text class="currency">¥</text>
          <text class="price">{{ displayPrice }}</text>
        </view>
        <text v-if="product.salesCount" class="sales">已完成 {{ product.salesCount }} 单</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  product: { type: Object, required: true },
  coverHeight: { type: Number, default: 240 },
  dense: { type: Boolean, default: false }
})

const imgError = ref(false)

const displayPrice = computed(() => {
  return Number(props.product.price || 0).toFixed(2)
})

const modeTag = computed(() => {
  const name = props.product.name || ''
  if (name.includes('大坝')) return '烽火地带 · 零号大坝'
  if (name.includes('长弓')) return '烽火地带 · 长弓溪谷'
  if (name.includes('航天')) return '烽火地带 · 航天基地'
  if (name.includes('巴克什')) return '烽火地带 · 巴克什'
  if (name.includes('全面战场')) return '全面战场 · 统帅冲榜'
  if (name.includes('特勤')) return '特勤处 · 部门升级'
  if (name.includes('小队') || name.includes('车队')) return '战术特训 · 连麦车队'
  return '特战护航'
})

const modeThemeClass = computed(() => {
  const name = props.product.name || ''
  if (name.includes('航天') || name.includes('砖')) return 'theme-gold'
  if (name.includes('全面战场')) return 'theme-cyan'
  if (name.includes('特勤')) return 'theme-purple'
  return 'theme-amber'
})

function goDetail() {
  uni.navigateTo({ url: `/pages/product/detail?id=${props.product.id}` })
}
</script>

<style lang="scss" scoped>
.product-card {
  background: #ffffff;
  border-radius: 16rpx;
  overflow: hidden;
  min-width: 0;
  border: 1rpx solid #e2e8f0;
  box-shadow: 0 4rpx 16rpx rgba(15, 23, 42, 0.05);
  display: flex;
  flex-direction: column;
  transition: transform 0.15s ease, box-shadow 0.15s ease;

  .cover-wrapper {
    position: relative;
    width: 100%;
    overflow: hidden;
    background: #0f172a;
  }

  .cover {
    width: 100%;
    height: 100%;
  }

  /* 战术战备风格卡面 */
  .tactical-cover {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 16rpx 18rpx;
    position: relative;
    background: linear-gradient(145deg, #0b1120 0%, #1e293b 100%);

    &.theme-amber {
      background: linear-gradient(145deg, #1e1b18 0%, #292014 60%, #15120e 100%);
      border-bottom: 2rpx solid rgba(245, 158, 11, 0.4);
      .tactical-badge { color: #fbbf24; border-color: rgba(245, 158, 11, 0.4); background: rgba(245, 158, 11, 0.15); }
      .tactical-center-emblem { color: #f59e0b; }
    }
    &.theme-cyan {
      background: linear-gradient(145deg, #091a24 0%, #0e2a3b 60%, #06151e 100%);
      border-bottom: 2rpx solid rgba(6, 182, 212, 0.4);
      .tactical-badge { color: #38bdf8; border-color: rgba(6, 182, 212, 0.4); background: rgba(6, 182, 212, 0.15); }
      .tactical-center-emblem { color: #06b6d4; }
    }
    &.theme-gold {
      background: linear-gradient(145deg, #241c09 0%, #3a2b0e 60%, #1c1507 100%);
      border-bottom: 2rpx solid rgba(234, 179, 8, 0.5);
      .tactical-badge { color: #fde047; border-color: rgba(234, 179, 8, 0.5); background: rgba(234, 179, 8, 0.2); }
      .tactical-center-emblem { color: #eab308; }
    }
    &.theme-purple {
      background: linear-gradient(145deg, #1a1228 0%, #2a1c42 60%, #130d20 100%);
      border-bottom: 2rpx solid rgba(168, 85, 247, 0.4);
      .tactical-badge { color: #c084fc; border-color: rgba(168, 85, 247, 0.4); background: rgba(168, 85, 247, 0.15); }
      .tactical-center-emblem { color: #a855f7; }
    }

    .tactical-hud-grid {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-image: linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                        linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
      background-size: 20rpx 20rpx;
      pointer-events: none;
    }

    .tactical-badge {
      align-self: flex-start;
      font-size: 20rpx;
      font-weight: 600;
      padding: 4rpx 12rpx;
      border-radius: 6rpx;
      border: 1rpx solid;
      letter-spacing: 1rpx;
      z-index: 1;
    }

    .tactical-center-emblem {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      margin: 10rpx 0;
      z-index: 1;

      .tactical-icon {
        font-size: 40rpx;
        line-height: 1;
      }
      .tactical-code {
        font-size: 18rpx;
        font-family: monospace;
        letter-spacing: 2rpx;
        opacity: 0.8;
        margin-top: 4rpx;
      }
    }

    .tactical-bottom-badge {
      display: flex;
      align-items: center;
      z-index: 1;

      .badge-dot {
        font-size: 14rpx;
        color: #10b981;
        margin-right: 6rpx;
      }
      .badge-text {
        font-size: 18rpx;
        color: #94a3b8;
        font-weight: 500;
      }
    }
  }

  .recommend-chip {
    position: absolute;
    top: 12rpx;
    right: 12rpx;
    background: #f59e0b;
    color: #0f172a;
    font-size: 18rpx;
    font-weight: 700;
    padding: 2rpx 10rpx;
    border-radius: 4rpx;
    letter-spacing: 1rpx;
    z-index: 2;
  }

  .info {
    padding: 16rpx 18rpx 18rpx;
    overflow: hidden;
    min-width: 0;
    display: flex;
    flex-direction: column;
    flex: 1;

    .name {
      font-size: 26rpx;
      font-weight: 700;
      color: #0f172a;
      line-height: 1.4;
      height: 72rpx;
    }

    .subtitle-wrap {
      min-width: 0;
      overflow: hidden;
      margin-top: 4rpx;
    }
    .subtitle {
      font-size: 20rpx;
      color: #64748b;
      display: block;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }

    .tag-row {
      display: flex;
      gap: 8rpx;
      margin-top: 10rpx;

      .tag-chip {
        font-size: 18rpx;
        color: #b45309;
        background: #fef3c7;
        padding: 2rpx 8rpx;
        border-radius: 4rpx;
        font-weight: 500;

        &.sec {
          color: #047857;
          background: #d1fae5;
        }
      }
    }

    .bottom {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      margin-top: 14rpx;

      .price-wrap {
        display: flex;
        align-items: baseline;
        color: #d97706;

        .currency {
          font-size: 24rpx;
          font-weight: 700;
          margin-right: 2rpx;
        }
        .price {
          font-size: 34rpx;
          font-weight: 800;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
      }

      .sales {
        font-size: 20rpx;
        color: #94a3b8;
      }
    }
  }

  &.dense {
    .info { padding: 12rpx 14rpx 14rpx; }
    .info .name { font-size: 24rpx; height: 68rpx; }
    .info .bottom .price { font-size: 30rpx; }
  }
}
</style>

