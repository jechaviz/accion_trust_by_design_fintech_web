<template>
  <main class="app-shell bg-[#f6f7f5]">
    <header class="topbar">
      <div>
        <p class="eyebrow">student_partner_track</p>
        <h1>Trust Layer Reporting</h1>
      </div>
      <div class="top-actions flex items-center gap-2">
        <button class="icon-button" title="Refresh report" @click="loadReport">
          <i data-lucide="refresh-cw"></i>
        </button>
        <a class="text-button" href="./data/trust_report.json" target="_blank" rel="noreferrer">
          <i data-lucide="file-json"></i>
          JSON
        </a>
      </div>
    </header>

    <section class="summary-grid grid gap-2">
      <article class="metric-tile accent-orange">
        <span>Trust score</span>
        <strong>{{ report.overall_score }}</strong>
        <small>/100 synthetic engine sample</small>
      </article>
      <article class="metric-tile accent-teal">
        <span>Women share</span>
        <strong>{{ report.women_user_pct }}%</strong>
        <small>sample customer mix</small>
      </article>
      <article class="metric-tile accent-green">
        <span>GDD coverage</span>
        <strong>{{ genderCount }}</strong>
        <small>gender cohorts reported</small>
      </article>
      <article class="metric-tile accent-red">
        <span>Partner gates</span>
        <strong>{{ partnerGateCount }}</strong>
        <small>must close before submit</small>
      </article>
    </section>

    <section class="workspace">
      <nav class="side-panel">
        <button :class="tabClass('metrics')" @click="activeTab = 'metrics'">
          <i data-lucide="bar-chart-3"></i>
          Metrics
        </button>
        <button :class="tabClass('signals')" @click="activeTab = 'signals'">
          <i data-lucide="shield-check"></i>
          Signals
        </button>
        <button :class="tabClass('readiness')" @click="activeTab = 'readiness'">
          <i data-lucide="clipboard-check"></i>
          Readiness
        </button>
        <img src="./assets/trust_by_design_guide.png" alt="Trust by Design guide cover" />
      </nav>

      <section class="content-panel" v-if="activeTab === 'metrics'">
        <div class="section-heading">
          <h2>Gender-Disaggregated Metrics</h2>
          <p>{{ report.total_events }} trust events processed by the V engine.</p>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Gender</th>
                <th>Customers</th>
                <th>Active</th>
                <th>Trust</th>
                <th>Retention</th>
                <th>Fraud loss prevented</th>
                <th>Complaints</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="metric in report.metrics" :key="metric.gender">
                <td>{{ metric.gender }}</td>
                <td>{{ metric.customer_count }}</td>
                <td>{{ metric.active_users }}</td>
                <td>{{ metric.avg_trust_score }}</td>
                <td>{{ metric.retention_rate_pct }}%</td>
                <td>{{ money(metric.fraud_loss_prevented_cents) }}</td>
                <td>{{ metric.complaints_resolved }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <section class="content-panel" v-if="activeTab === 'signals'">
        <div class="section-heading">
          <h2>Trust Signals</h2>
          <p>Customer-facing safeguards generated from event-level trust decisions.</p>
        </div>
        <div class="signal-list">
          <article v-for="decision in report.decisions" :key="decision.event_id" class="signal-row">
            <div>
              <strong>{{ decision.event_id }}</strong>
              <span>{{ decision.customer_explanation }}</span>
            </div>
            <div class="risk-pill" :data-risk="decision.risk">{{ decision.risk }} {{ decision.score }}</div>
          </article>
        </div>
      </section>

      <section class="content-panel" v-if="activeTab === 'readiness'">
        <div class="section-heading">
          <h2>Application Readiness</h2>
          <p>Final submission remains gated until partner authority and live metrics replace the sample.</p>
        </div>
        <div class="finding-list">
          <article v-for="finding in report.findings" :key="finding.id" class="finding-row">
            <span :class="['status-dot', finding.status]"></span>
            <div>
              <strong>{{ title(finding.id) }}</strong>
              <small>{{ finding.message }}</small>
            </div>
            <span class="status-label">{{ finding.status }}</span>
          </article>
        </div>
      </section>
    </section>
  </main>
</template>

<script>
export default {
  name: 'TrustReportApp',
  data() {
    return {
      activeTab: 'metrics',
      report: {
        total_events: 0,
        overall_score: 0,
        women_user_pct: 0,
        metrics: [],
        decisions: [],
        findings: []
      }
    };
  },
  computed: {
    partnerGateCount() {
      return this.report.findings.filter((item) => item.status !== 'pass').length;
    },
    genderCount() {
      return this.report.metrics.length;
    }
  },
  mounted() {
    this.loadReport();
  },
  updated() {
    this.paintIcons();
  },
  methods: {
    async loadReport() {
      const response = await fetch('./data/trust_report.json', { cache: 'no-store' });
      this.report = await response.json();
      this.$nextTick(this.paintIcons);
    },
    paintIcons() {
      if (window.lucide) window.lucide.createIcons();
    },
    tabClass(tab) {
      return ['nav-button', { active: this.activeTab === tab }];
    },
    money(cents) {
      return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(cents / 100);
    },
    title(value) {
      return value.replaceAll('_', ' ');
    }
  }
};
</script>
