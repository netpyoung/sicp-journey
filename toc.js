// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><a href="Index.html">대문</a></li><li class="chapter-item expanded "><a href="intro.html">들어가며</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="etc/drracket.html">DrRacket</a></li></ol></li><li class="chapter-item expanded "><li class="part-title">챕터</li><li class="chapter-item expanded "><a href="chapter/ch01.html">1장. 함수로 추상화 쌓기</a></li><li class="chapter-item expanded "><a href="chapter/ch02.html">2장. 데이터로 추상화 쌓기</a></li><li class="chapter-item expanded "><a href="chapter/ch03.html">3장. 모듈, 객체, 상태</a></li><li class="chapter-item expanded "><a href="chapter/ch04.html">4장. 메타언어적 추상화</a></li><li class="chapter-item expanded "><a href="chapter/ch05.html">5장. 레지스터 머신으로 계산</a></li><li class="chapter-item expanded affix "><li class="part-title">연습문제</li><li class="chapter-item expanded "><a href="solution/solution_index.html">연습문제</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="solution/solution_ch01.html">풀이 01</a></li><li class="chapter-item expanded "><a href="solution/solution_ch02.html">풀이 02</a></li><li class="chapter-item expanded "><a href="solution/solution_ch03.html">풀이 03</a></li><li class="chapter-item expanded "><a href="solution/solution_ch04.html">풀이 04</a></li><li class="chapter-item expanded "><a href="solution/solution_ch05.html">풀이 05</a></li></ol></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
