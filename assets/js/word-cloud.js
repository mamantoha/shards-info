import cloud from 'd3-cloud';
import * as d3 from 'd3';

const DEFAULTS = {
  steps: 5,
  padding: 1,
  rotate: () => {
    const angles = [0, 60, -60];
    return angles[Math.floor(Math.random() * angles.length)];
  },
  autoResize: false,
  classPattern: 'w{n}',
  fontSize: {
    from: 0.04,
    to: 0.01
  }
};

function resolveElement (container) {
  if (typeof container === 'string') {
    return document.querySelector(container);
  }

  return container;
}

function ensureNumber (value, fallback = 0) {
  const parsed = Number.parseFloat(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function computeStep (weight, minWeight, maxWeight, steps) {
  if (maxWeight === minWeight) {
    return Math.floor(steps / 2);
  }

  // Use logarithmic scale for better distribution
  const logWeight = Math.log(weight + 1);
  const logMin = Math.log(minWeight + 1);
  const logMax = Math.log(maxWeight + 1);

  return Math.round(((logWeight - logMin) * (steps - 1)) / (logMax - logMin)) + 1;
}

function computeSize (width, step, steps, fontSize) {
  const maxSize = width * fontSize.from;
  const minSize = width * fontSize.to;
  const size = minSize + ((maxSize - minSize) / (steps - 1)) * (step - 1);

  return Math.max(1, Math.round(size));
}

function normalizeLink (link) {
  if (!link) {
    return null;
  }

  if (typeof link === 'string') {
    return { href: link };
  }

  return link;
}

function drawWordCloud (container, words, options = {}) {
  const element = resolveElement(container);

  if (!element) {
    return;
  }

  const settings = {
    ...DEFAULTS,
    ...options,
    fontSize: {
      ...DEFAULTS.fontSize,
      ...(options.fontSize || {})
    }
  };

  // Ensure rotate is a function
  if (typeof settings.rotate !== 'function') {
    const fixedRotation = settings.rotate;
    settings.rotate = () => fixedRotation;
  }

  const width = element.clientWidth || element.offsetWidth;
  const height = element.clientHeight || element.offsetHeight;

  const lastSize = element._wordCloudLastSize || {};
  if (lastSize.width === width && lastSize.height === height && options._isResize) {
    return;
  }

  element._wordCloudLastSize = { width, height };

  if (!width || !height) {
    return;
  }

  const data = Array.isArray(words) ? words : [];
  const weights = data.map((word) => ensureNumber(word.weight));
  const maxWeight = weights.length ? Math.max(...weights) : 0;
  const minWeight = weights.length ? Math.min(...weights) : 0;

  const layoutWords = data.map((word) => {
    const weight = ensureNumber(word.weight);
    const step = computeStep(weight, minWeight, maxWeight, settings.steps);
    const size = computeSize(width, step, settings.steps, settings.fontSize);

    return {
      text: word.text,
      size,
      step,
      color: word.color,
      link: normalizeLink(word.link),
      raw: word
    };
  });

  element.classList.add('word-cloud');
  element.innerHTML = '';

  const layout = cloud()
    .size([width, height])
    .words(layoutWords)
    .padding(settings.padding)
    .rotate(settings.rotate)
    .font('Helvetica, Arial, sans-serif')
    .fontSize((d) => d.size)
    .on('end', (renderedWords) => {
      const svg = d3
        .select(element)
        .append('svg')
        .attr('class', 'word-cloud__svg')
        .attr('width', width)
        .attr('height', height)
        .attr('viewBox', `0 0 ${width} ${height}`);

      const group = svg
        .append('g')
        .attr('transform', `translate(${width / 2},${height / 2})`);

      const nodes = group
        .selectAll('g')
        .data(renderedWords)
        .enter()
        .append('g')
        .attr('transform', (d) => `translate(${d.x},${d.y})rotate(${d.rotate})`);

      const addText = (selection) => {
        selection
          .attr('class', (d) => `word-cloud__word ${settings.classPattern.replace('{n}', d.step)}`)
          .style('font-size', (d) => `${d.size}px`)
          .style('fill', (d) => d.color || null)
          .attr('text-anchor', 'middle')
          .text((d) => d.text);
      };

      nodes.each(function (d) {
        if (d.link && d.link.href) {
          const link = d3
            .select(this)
            .append('a')
            .attr('class', 'word-cloud__link')
            .attr('href', d.link.href);

          if (d.link.target) {
            link.attr('target', d.link.target);
          }

          if (d.link.rel) {
            link.attr('rel', d.link.rel);
          }

          addText(link.append('text'));
        } else {
          addText(d3.select(this).append('text'));
        }
      });
    });

  layout.start();

  if (settings.autoResize) {
    if (element._wordCloudObserver) {
      element._wordCloudObserver.disconnect();
    }

    let resizeTimeout;
    element._wordCloudObserver = new ResizeObserver(() => {
      window.clearTimeout(resizeTimeout);
      resizeTimeout = window.setTimeout(() => {
        drawWordCloud(element, words, { ...settings, _isResize: true });
      }, 150);
    });

    element._wordCloudObserver.observe(element);
  }
}

window.renderWordCloud = drawWordCloud;

export default drawWordCloud;
