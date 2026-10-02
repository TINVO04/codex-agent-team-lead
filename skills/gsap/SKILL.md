---
name: gsap
description: Kỹ năng chuyên sâu về GreenSock Animation Platform (GSAP 3.x), ScrollTrigger, useGSAP (React/Next.js), Timeline, và GPU-accelerated motion. Dùng khi xây dựng landing page, hiệu ứng cuộn trang, hero animation, micro-interaction hoặc tối ưu chuyển động 60fps mượt mà không gây giật lag (re-flow/memory leak).
license: MIT
metadata:
  vendor: GreenSock (Official)
  category: frontend-motion
  compatibility: React, Next.js, Vue, Nuxt, Svelte, Vanilla JS
---

# GSAP Motion & Animation Engine (Chuẩn GreenSock & Codex Team Lead)

Thư viện chuẩn công nghiệp cho hoạt ảnh JavaScript hiệu năng cao. Áp dụng cho mọi tác vụ giao diện cần chuyển động mượt mà, ScrollTrigger, hiệu ứng xuất hiện (entrance), chuyển cảnh trang (page transition) hoặc tương tác micro-interactions.

---

## 1. Khi nào Big Lead giao skill này cho Worker?

- **Task Scope:** Khi task thuộc tầng **Level 2 (Standard Scope)** hoặc **Level 3 (Enterprise Swarm)** liên quan đến:
  - Thiết kế/nâng cấp Landing Page (Hero section, storytelling scroll).
  - Thêm hiệu ứng cuộn (ScrollTrigger, pinning, scrubbing, horizontal scroll, snapping).
  - Hoạt cảnh tuần tự (Timeline sequences, SVG morphing, text reveal, split-text).
  - Tối ưu FPS, sửa lỗi giật lag animation hoặc rò rỉ bộ nhớ (memory leak) do animation cũ.
- **Cơ chế nạp On-Demand:** Big Lead chỉ định trong Task Contract: `[role: frontend] [skill: gsap]`. Big Lead **không** nạp skill này vào prompt điều phối toàn cục để tiết kiệm token.

---

## 2. Các nguyên tắc bắt buộc cho AI Worker (Zero-Hallucination Rules)

### Quy tắc 1: Cấm tuyệt đối cú pháp cũ (Legacy TweenMax / TimelineMax)
- **SAI (Cấm):** `TweenMax.to(...)`, `TimelineMax()`, `new TimelineLite()`.
- **ĐÚNG (GSAP 3):**
  ```javascript
  import { gsap } from "gsap";
  import { ScrollTrigger } from "gsap/ScrollTrigger";
  gsap.registerPlugin(ScrollTrigger);

  gsap.to(".target", { x: 100, autoAlpha: 1, duration: 0.6, ease: "power2.out" });
  ```

### Quy tắc 2: Tối ưu phần cứng GPU — Cấm animate layout-triggering properties
- **SAI (Gây giật lag re-flow):** Animate `top`, `left`, `bottom`, `right`, `width`, `height`, `margin`, `padding`.
- **ĐÚNG (GPU transform 60fps):**
  - Vị trí: `x`, `y`, `xPercent`, `yPercent` (tương đương `transform: translate3d`).
  - Kích thước/Góc: `scale`, `scaleX`, `scaleY`, `rotation`, `rotationX`, `rotationY`.
  - Hiển thị: Dùng `autoAlpha` (kết hợp `opacity` + `visibility: hidden` để tối ưu render tree).

### Quy tắc 3: Chuẩn tích hợp React & Next.js (Bắt buộc dùng `useGSAP`)
Khi code trong React / Next.js (App Router / Pages Router):
- Cài đặt `@gsap/react` và đăng ký plugin:
  ```javascript
  import { gsap } from "gsap";
  import { useGSAP } from "@gsap/react";
  import { useRef } from "react";

  gsap.registerPlugin(useGSAP);

  export default function HeroSection() {
    const containerRef = useRef(null);

    useGSAP(() => {
      // Mọi animation phải nằm trong useGSAP có scope để tự động cleanup
      gsap.from(".hero-title", {
        y: 50,
        autoAlpha: 0,
        duration: 0.8,
        ease: "power3.out",
        stagger: 0.2
      });
    }, { scope: containerRef }); // Scope bắt buộc để tránh query selector rò rỉ ra toàn trang

    return (
      <div ref={containerRef} className="hero-container">
        <h1 className="hero-title">Tiêu đề xịn xò</h1>
        <p className="hero-title">Nội dung hỗ trợ</p>
      </div>
    );
  }
  ```
- **Lưu ý:** Không bao giờ viết animation trong `useEffect` trần trụi mà không có `gsap.context()` revert, vì sẽ gây nhân đôi animation khi React Strict Mode kích hoạt.

### Quy tắc 4: Chuẩn ScrollTrigger (Scroll-Linked Animation)
```javascript
const tl = gsap.timeline({
  scrollTrigger: {
    trigger: ".features-section",
    start: "top 80%",    // Khi đỉnh section chạm 80% viewport
    end: "bottom 20%",
    toggleActions: "play none none reverse", // Vào thì play, cuộn ngược lại thì reverse
    scrub: 1             // Smooth scrub 1 giây theo tốc độ lăn chuột
  }
});

tl.from(".feature-card", {
  y: 60,
  autoAlpha: 0,
  stagger: 0.15,
  ease: "power2.out"
});
```
- Nếu có layout thay đổi bất đồng bộ (load ảnh, fetch API), bắt buộc gọi: `ScrollTrigger.refresh()`.

---

## 3. Tài liệu chi tiết từng phân hệ (References)

Khi cần tra cứu sâu từng phân hệ, worker đọc file markdown tương ứng trong thư mục `references/`:
1. [Core API & Tweens](references/core.md) (`references/core.md`): `gsap.to()`, `from()`, `fromTo()`, easing functions, stagger, matchMedia responsive.
2. [React & Next.js Integration](references/react.md) (`references/react.md`): Hook `useGSAP`, component lifecycle, scoped selectors, SSR context.
3. [ScrollTrigger & Smooth Scroll](references/scrolltrigger.md) (`references/scrolltrigger.md`): Pinning, scrubbing, snapping, responsive triggers, ScrollSmoother.
4. [Timelines & Sequencing](references/timeline.md) (`references/timeline.md`): Timeline nesting, position parameters (`+=`, `-=`, `<`), labels, timeline controls.
5. [Performance & GPU Optimization](references/performance.md) (`references/performance.md`): `will-change`, batching, tránh layout thrashing.
6. [GSAP Plugins](references/plugins.md) (`references/plugins.md`): Flip (FLIP animation), Draggable, MotionPath, TextPlugin, SplitText.
7. [Vue, Nuxt & Svelte](references/frameworks.md) (`references/frameworks.md`): Hướng dẫn cho Vue 3 Composition API và Svelte onMount.
8. [Utility Helpers](references/utils.md) (`references/utils.md`): `gsap.utils.clamp`, `mapRange`, `interpolate`, `random`, `toArray`.
