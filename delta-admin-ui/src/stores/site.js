import { defineStore } from 'pinia'
import { ref } from 'vue'
import request from '@/utils/request'

export const useSiteStore = defineStore('site', () => {
  const siteName = ref('三角洲特战服务中心')
  const subtitle = ref('三角洲行动专业护航摸金接单平台')
  const logo = ref('')
  const adminTitle = ref('三角洲行动特战运营管理后台')
  const loaded = ref(false)

  async function fetchSiteConfig() {
    if (loaded.value) return
    try {
      const res = await request({ url: '/system/config/site', method: 'get' })
      const data = res.data || {}
      if (data.site_name) siteName.value = data.site_name
      if (data.site_subtitle) subtitle.value = data.site_subtitle
      if (data.site_logo) logo.value = data.site_logo
      if (data.site_admin_title) adminTitle.value = data.site_admin_title
      loaded.value = true
      // 同步更新页面 title
      document.title = adminTitle.value
    } catch (e) {
      console.warn('[SiteStore] fetch site config failed', e)
    }
  }

  return { siteName, subtitle, logo, adminTitle, loaded, fetchSiteConfig }
})
