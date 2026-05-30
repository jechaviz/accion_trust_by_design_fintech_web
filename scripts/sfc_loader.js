(function () {
  function pick(source, tag) {
    const match = source.match(new RegExp(`<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`));
    return match ? match[1].trim() : '';
  }

  async function loadSimpleSfc(url) {
    const response = await fetch(url, { cache: 'no-store' });
    if (!response.ok) throw new Error(`${url} ${response.status}`);
    const source = await response.text();
    const template = pick(source, 'template');
    const script = pick(source, 'script').replace('export default', 'return');
    const styleText = pick(source, 'style');
    if (styleText) {
      const style = document.createElement('style');
      style.textContent = styleText;
      document.head.appendChild(style);
    }
    const component = Function(script)();
    component.template = template;
    return component;
  }

  window.loadSimpleSfc = loadSimpleSfc;
})();
