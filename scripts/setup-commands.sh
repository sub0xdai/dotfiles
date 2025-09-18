#!/bin/bash

# Testudo Trade Commands Folder Structure Setup
# This script creates the complete commands folder structure for use with Claude Code

echo "🚀 Creating Testudo Trade Commands folder structure..."

# Create main commands directory
mkdir -p commands

# Create all subdirectories
mkdir -p commands/development
mkdir -p commands/exchanges
mkdir -p commands/risk-management
mkdir -p commands/infrastructure
mkdir -p commands/testing
mkdir -p commands/documentation
mkdir -p commands/security
mkdir -p commands/mvp
mkdir -p commands/monitoring
mkdir -p commands/optimization
mkdir -p commands/market-analysis
mkdir -p commands/productivity

echo "📁 Created directory structure"

# Development Commands
cat > commands/development/architecture-review.md << 'EOF'
# Architecture Review Prompt

Review the system architecture for {COMPONENT_NAME} in the context of a crypto trading platform.

**Context:**
- Platform: Testudo Trade (centralized exchange perp trading automation)
- Component: {COMPONENT_NAME}
- Current Implementation: {CURRENT_STATE}

**Review Criteria:**
1. **Security**: API key handling, data encryption, vulnerability assessment
2. **Performance**: Latency requirements, throughput, scalability
3. **Reliability**: Error handling, failover mechanisms, data consistency
4. **Maintainability**: Code organization, documentation, testing coverage

**Focus Areas:**
- {FOCUS_AREA_1}
- {FOCUS_AREA_2}
- {FOCUS_AREA_3}

**Deliverables:**
- Architecture assessment
- Security recommendations
- Performance optimization suggestions
- Implementation roadmap

**Technical Constraints:**
- Budget: MVP-focused
- Timeline: {TIMELINE}
- Team Size: Solo developer
EOF

cat > commands/development/code-review.md << 'EOF'
# Code Review Prompt

Perform a comprehensive code review for {FILE_PATH} in Testudo Trade.

**Review Context:**
- Component: {COMPONENT_TYPE} (API, Frontend, Database, etc.)
- Language: {PROGRAMMING_LANGUAGE}
- Framework: {FRAMEWORK}

**Review Checklist:**
1. **Security**: Input validation, SQL injection prevention, API key protection
2. **Performance**: Algorithm efficiency, memory usage, database queries
3. **Error Handling**: Exception management, logging, user feedback
4. **Code Quality**: Readability, maintainability, adherence to patterns
5. **Testing**: Unit test coverage, integration test needs

**Crypto Trading Specific:**
- Exchange API error handling
- Rate limiting compliance
- Order execution safety
- Risk management validation
- Real-time data processing

**Output Format:**
- Critical issues (security/functionality)
- Performance optimizations
- Code quality improvements
- Testing recommendations
EOF

cat > commands/development/debug-issue.md << 'EOF'
# Debug Issue Prompt

Debug the following issue in Testudo Trade:

**Issue Description:**
{ISSUE_DESCRIPTION}

**Component:** {COMPONENT_NAME}
**Environment:** {ENVIRONMENT} (Development/Staging/Production)
**Error Messages:**
```
{ERROR_LOGS}
```

**Context:**
- User Action: {USER_ACTION}
- Expected Behavior: {EXPECTED_BEHAVIOR}
- Actual Behavior: {ACTUAL_BEHAVIOR}
- Frequency: {FREQUENCY}

**System State:**
- Exchange: {EXCHANGE_NAME}
- Market Conditions: {MARKET_CONDITIONS}
- User Load: {CONCURRENT_USERS}

**Debug Strategy:**
1. Root cause analysis
2. Reproduction steps
3. Fix recommendations
4. Prevention measures
5. Monitoring improvements

**Priority:** {PRIORITY_LEVEL}
EOF

# Exchange Commands
cat > commands/exchanges/integrate-exchange.md << 'EOF'
# Exchange Integration Prompt

Integrate {EXCHANGE_NAME} API into Testudo Trade platform.

**Exchange Details:**
- Name: {EXCHANGE_NAME}
- API Version: {API_VERSION}
- Documentation: {API_DOCS_URL}
- Rate Limits: {RATE_LIMITS}

**Integration Requirements:**
1. **Authentication**: API key management, signature generation
2. **Market Data**: Real-time prices, order book, trade history
3. **Trading Operations**: Place/cancel orders, position management
4. **Account Data**: Balance queries, position status, trade history

**Risk Management Integration:**
- Position sizing calculations
- Stop-loss automation
- Take-profit management
- Liquidation prevention

**Error Handling:**
- Network timeouts
- Rate limit exceeded
- Invalid parameters
- Exchange downtime

**Testing Strategy:**
- Testnet integration first
- Paper trading validation
- Gradual rollout plan

**Deliverables:**
- Exchange adapter implementation
- Unit and integration tests
- Documentation and examples
- Error handling procedures
EOF

cat > commands/exchanges/test-exchange-api.md << 'EOF'
# Exchange API Testing Prompt

Create comprehensive tests for {EXCHANGE_NAME} API integration.

**Test Categories:**
1. **Authentication Tests**
   - API key validation
   - Signature generation
   - Permission levels

2. **Market Data Tests**
   - Real-time price feeds
   - Order book accuracy
   - Historical data retrieval

3. **Trading Function Tests**
   - Order placement: {ORDER_TYPES}
   - Order cancellation
   - Position management
   - Balance queries

4. **Error Scenario Tests**
   - Network failures
   - Invalid parameters
   - Rate limit handling
   - Exchange maintenance

**Risk Management Tests:**
- Stop-loss trigger accuracy
- Position size calculations
- Risk threshold enforcement

**Performance Tests:**
- Latency measurements
- Throughput testing
- Concurrent request handling

**Test Environment:** {TEST_ENVIRONMENT}
**Expected Results:** {EXPECTED_OUTCOMES}
EOF

# Risk Management Commands
cat > commands/risk-management/design-risk-engine.md << 'EOF'
# Risk Engine Design Prompt

Design a risk management engine for Testudo Trade with the following parameters:

**Risk Parameters:**
- Max Risk Per Trade: {MAX_RISK_PERCENT}%
- Max Daily Loss: {MAX_DAILY_LOSS}%
- Position Size Method: {SIZING_METHOD}
- Stop Loss Strategy: {STOP_LOSS_STRATEGY}

**Risk Controls:**
1. **Pre-Trade Validation**
   - Account balance verification
   - Risk parameter compliance
   - Market condition checks

2. **Active Position Monitoring**
   - Real-time P&L tracking
   - Stop-loss execution
   - Take-profit management

3. **Portfolio-Level Controls**
   - Total exposure limits
   - Correlation checks
   - Drawdown protection

**Automation Features:**
- Automatic position sizing
- Dynamic stop-loss adjustment
- Emergency position closure
- Risk alert notifications

**Integration Points:**
- Exchange APIs: {EXCHANGE_LIST}
- User preferences
- Market data feeds
- Notification systems

**Performance Requirements:**
- Latency: <{MAX_LATENCY}ms
- Reliability: {UPTIME_TARGET}%
- Concurrent users: {MAX_USERS}
EOF

cat > commands/risk-management/validate-risk-rules.md << 'EOF'
# Risk Rules Validation Prompt

Validate risk management rules for the following scenario:

**Trading Scenario:**
- Exchange: {EXCHANGE_NAME}
- Symbol: {TRADING_PAIR}
- Position Size: {POSITION_SIZE}
- Entry Price: {ENTRY_PRICE}
- Stop Loss: {STOP_LOSS_PRICE}
- Take Profit: {TAKE_PROFIT_PRICE}

**User Risk Profile:**
- Account Balance: ${ACCOUNT_BALANCE}
- Risk Per Trade: {RISK_PERCENT}%
- Max Daily Loss: {MAX_DAILY_LOSS}%
- Leverage: {LEVERAGE}x

**Validation Checks:**
1. Position size within risk limits
2. Stop-loss distance appropriate
3. Risk-reward ratio acceptable
4. Account balance sufficient
5. Leverage within limits

**Market Conditions:**
- Volatility: {VOLATILITY_LEVEL}
- Liquidity: {LIQUIDITY_STATUS}
- Time of Day: {TRADING_HOURS}

**Expected Output:**
- Validation results (PASS/FAIL)
- Risk calculations
- Recommendations
- Alternative scenarios
EOF

# MVP Commands
cat > commands/mvp/validate-mvp-feature.md << 'EOF'
# MVP Feature Validation Prompt

Validate if {FEATURE_NAME} should be included in Testudo Trade MVP.

**Feature Details:**
- Feature: {FEATURE_NAME}
- Estimated Development Time: {DEV_TIME_HOURS} hours
- Complexity Level: {COMPLEXITY} (Low/Medium/High)
- Dependencies: {DEPENDENCIES}

**Validation Criteria:**
1. **User Value Assessment**
   - Core user problem solved: {PROBLEM_DESCRIPTION}
   - User pain level (1-10): {PAIN_LEVEL}
   - Frequency of use: {USAGE_FREQUENCY}
   - Alternative solutions available: {ALTERNATIVES}

2. **Business Impact**
   - Revenue impact: {REVENUE_IMPACT}
   - User retention impact: {RETENTION_IMPACT}
   - Competitive advantage: {COMPETITIVE_ADVANTAGE}
   - Market differentiation: {DIFFERENTIATION}

3. **Technical Feasibility**
   - Implementation complexity: {TECHNICAL_COMPLEXITY}
   - Integration requirements: {INTEGRATION_NEEDS}
   - Security implications: {SECURITY_CONSIDERATIONS}
   - Performance impact: {PERFORMANCE_IMPACT}

**Decision Framework:**
- MUST HAVE: Core trading functionality, risk management, basic UI
- SHOULD HAVE: Enhanced UX, additional exchanges, reporting
- COULD HAVE: Advanced analytics, social features, mobile app
- WON'T HAVE: Non-essential features, nice-to-haves

**Recommendation:** {INCLUDE_IN_MVP} (Include/Defer/Reject)
**Reasoning:** {DECISION_REASONING}
EOF

cat > commands/mvp/prioritize-backlog.md << 'EOF'
# Backlog Prioritization Prompt

Prioritize development backlog for Testudo Trade solo development.

**Current Context:**
- Development Phase: {CURRENT_PHASE} (MVP/Post-MVP/Scale)
- Available Time: {WEEKLY_HOURS} hours/week
- Target Launch Date: {LAUNCH_DATE}
- Current User Count: {USER_COUNT}

**Prioritization Framework:**
1. **Impact vs Effort Matrix**
   - High Impact, Low Effort: Priority 1
   - High Impact, High Effort: Priority 2
   - Low Impact, Low Effort: Priority 3
   - Low Impact, High Effort: Priority 4

2. **User Journey Critical Path**
   - Account setup and exchange connection
   - Risk profile configuration
   - Trade execution workflow
   - Position monitoring and management

**Solo Developer Constraints:**
- Knowledge gaps requiring learning
- Complex features needing extended focus
- Features requiring external dependencies

**Output Required:**
- Sprint 1 priorities (2-week sprint)
- Sprint 2-4 roadmap
- Parking lot (future features)
- Technical debt items
EOF

cat > commands/mvp/mvp-architecture-decision.md << 'EOF'
# MVP Architecture Decision Prompt

Make architecture decision for {DECISION_TOPIC} in Testudo Trade MVP.

**Decision Context:**
- Component: {COMPONENT_NAME}
- Problem: {PROBLEM_STATEMENT}
- Constraints: {CONSTRAINTS}
- Timeline: {DECISION_DEADLINE}

**Evaluation Criteria:**
1. **MVP Speed to Market**
   - Development time impact
   - Learning curve required
   - Integration complexity

2. **Scalability Considerations**
   - User growth accommodation (10 → 1000 users)
   - Performance implications
   - Infrastructure costs

3. **Maintenance Burden**
   - Solo developer sustainability
   - Documentation requirements
   - Debugging complexity

**Decision Matrix:**
| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| Speed | {SCORE_A} | {SCORE_B} | {SCORE_C} |
| Scale | {SCORE_A} | {SCORE_B} | {SCORE_C} |
| Maintenance | {SCORE_A} | {SCORE_B} | {SCORE_C} |

**Recommendation:** {RECOMMENDED_OPTION}
**Implementation Plan:** {IMPLEMENTATION_STEPS}
EOF

# Monitoring Commands
cat > commands/monitoring/setup-alerts.md << 'EOF'
# System Alerts Setup Prompt

Configure monitoring alerts for {SYSTEM_COMPONENT} in Testudo Trade.

**Component:** {COMPONENT_NAME}
**Environment:** {ENVIRONMENT}
**Criticality Level:** {CRITICALITY} (Critical/High/Medium/Low)

**Alert Categories:**
1. **System Health**
   - CPU usage > {CPU_THRESHOLD}%
   - Memory usage > {MEMORY_THRESHOLD}%
   - Disk space < {DISK_THRESHOLD}%

2. **Trading-Specific Alerts**
   - Exchange API failures
   - Order execution delays > {ORDER_DELAY_THRESHOLD}ms
   - Risk management failures
   - Position synchronization errors

3. **Security Alerts**
   - Failed authentication attempts > {AUTH_FAILURE_THRESHOLD}
   - Unusual API key usage patterns
   - Suspicious trading behavior

**Alert Configuration:**
- Notification channels: {NOTIFICATION_CHANNELS}
- Escalation policy: {ESCALATION_POLICY}
- Business hours vs after-hours handling

**Testing Strategy:**
- Alert testing procedures
- False positive handling
- Performance impact assessment
EOF

cat > commands/monitoring/performance-analysis.md << 'EOF'
# Performance Analysis Prompt

Analyze performance issue for {COMPONENT_NAME} in Testudo Trade.

**Issue Context:**
- Component: {COMPONENT_NAME}
- Symptom: {PERFORMANCE_SYMPTOM}
- Impact: {USER_IMPACT}
- Environment: {ENVIRONMENT}

**Analysis Areas:**
1. **Application Layer**
   - Code efficiency
   - Algorithm complexity
   - Memory leaks
   - Blocking operations

2. **Database Layer**
   - Query performance
   - Index utilization
   - Connection pooling

3. **Network Layer**
   - API call efficiency
   - Exchange latency
   - Bandwidth utilization

**Trading-Specific Considerations:**
- Market data processing efficiency
- Order execution speed
- Risk calculation performance

**Optimization Recommendations:**
- Immediate fixes: {IMMEDIATE_FIXES}
- Short-term improvements: {SHORT_TERM_IMPROVEMENTS}
- Long-term optimizations: {LONG_TERM_OPTIMIZATIONS}
EOF

cat > commands/monitoring/user-behavior-analysis.md << 'EOF'
# User Behavior Analysis Prompt

Analyze user behavior patterns for {FEATURE_NAME} in Testudo Trade.

**Analysis Context:**
- Feature: {FEATURE_NAME}
- Time Period: {ANALYSIS_PERIOD}
- User Segment: {USER_SEGMENT}

**Behavior Metrics:**
1. **Engagement Metrics**
   - Daily/Weekly/Monthly active users
   - Session duration
   - Feature adoption rate

2. **Trading Behavior**
   - Trading frequency
   - Position sizes
   - Risk tolerance settings
   - Exchange preferences

**Insights & Recommendations:**
- User experience improvements
- Feature enhancement priorities
- Onboarding optimization
- Risk management education needs
EOF

# Optimization Commands
cat > commands/optimization/optimize-api-calls.md << 'EOF'
# API Call Optimization Prompt

Optimize exchange API calls for {EXCHANGE_NAME} in Testudo Trade.

**Current State:**
- Exchange: {EXCHANGE_NAME}
- Current API call volume: {CURRENT_CALL_VOLUME}/minute
- Rate limit: {RATE_LIMIT}/minute
- Current utilization: {UTILIZATION_PERCENTAGE}%

**Optimization Strategies:**
1. **Caching Implementation**
   - Cache duration for market data: {MARKET_DATA_CACHE_TTL}
   - Cache duration for account data: {ACCOUNT_DATA_CACHE_TTL}

2. **Batch Operations**
   - Batch market data requests
   - Bulk order status queries
   - Aggregate position updates

3. **WebSocket Integration**
   - Real-time market data streams
   - Order update notifications
   - Account balance changes

**Expected Improvements:**
- API call reduction: {EXPECTED_REDUCTION}%
- Latency improvement: {LATENCY_IMPROVEMENT}ms
- Cost savings: ${COST_SAVINGS}/month
EOF

cat > commands/optimization/database-optimization.md << 'EOF'
# Database Optimization Prompt

Optimize database performance for {DATABASE_COMPONENT} in Testudo Trade.

**Database Context:**
- Database: {DATABASE_TYPE}
- Component: {COMPONENT_NAME}
- Current Performance: {CURRENT_PERFORMANCE}
- Target Performance: {TARGET_PERFORMANCE}

**Optimization Areas:**
1. **Index Optimization**
   - Missing indexes: {MISSING_INDEXES}
   - Unused indexes: {UNUSED_INDEXES}
   - Composite index opportunities: {COMPOSITE_INDEX_OPPORTUNITIES}

2. **Query Optimization**
   - Query rewriting opportunities
   - Subquery optimization
   - Join optimization

3. **Schema Optimization**
   - Table partitioning: {PARTITIONING_STRATEGY}
   - Archive strategy: {ARCHIVAL_STRATEGY}

**Trading-Specific Optimizations:**
- Real-time data insertion optimization
- Historical data querying
- Position calculation efficiency
EOF

cat > commands/optimization/cost-analysis.md << 'EOF'
# Infrastructure Cost Analysis Prompt

Analyze and optimize infrastructure costs for Testudo Trade.

**Current Infrastructure:**
- Cloud Provider: {CLOUD_PROVIDER}
- Monthly Cost: ${CURRENT_MONTHLY_COST}
- User Count: {CURRENT_USERS}
- Cost per User: ${COST_PER_USER}

**Cost Breakdown:**
1. **Compute Costs**
   - Application servers: ${COMPUTE_COSTS}
   - Background workers: ${WORKER_COSTS}

2. **Storage Costs**
   - Database storage: ${DB_STORAGE_COSTS}
   - File storage: ${FILE_STORAGE_COSTS}

3. **Third-Party Services**
   - Monitoring tools: ${MONITORING_COSTS}
   - Security services: ${SECURITY_COSTS}

**Optimization Opportunities:**
- Right-sizing resources: {OPTIMIZATION_SUGGESTIONS}
- Reserved instance savings: ${RI_SAVINGS}
- Alternative architectures: {ARCHITECTURE_ALTERNATIVES}

**Implementation Priority:**
1. Quick wins: {QUICK_WINS}
2. Medium effort: {MEDIUM_EFFORT_ITEMS}
3. Long-term projects: {LONG_TERM_PROJECTS}
EOF

# Infrastructure Commands
cat > commands/infrastructure/design-database-schema.md << 'EOF'
# Database Schema Design Prompt

Design database schema for {FEATURE_NAME} in Testudo Trade.

**Requirements:**
- Data Type: {DATA_TYPE} (Users, Trades, Positions, etc.)
- Scale: {EXPECTED_VOLUME} records
- Query Patterns: {QUERY_PATTERNS}

**Schema Components:**
1. **Core Tables**
   - Primary entities
   - Relationships
   - Indexes

2. **Performance Optimization**
   - Query optimization
   - Caching strategy
   - Partitioning needs

3. **Data Integrity**
   - Constraints
   - Validation rules
   - Backup strategy

**Security Considerations:**
- Sensitive data encryption
- Access controls
- Audit trails
EOF

cat > commands/infrastructure/deploy-infrastructure.md << 'EOF'
# Infrastructure Deployment Prompt

Design deployment infrastructure for Testudo Trade {ENVIRONMENT}.

**Environment:** {ENVIRONMENT} (Development/Staging/Production)
**Cloud Provider:** {CLOUD_PROVIDER}
**Budget Constraint:** ${MONTHLY_BUDGET}

**Infrastructure Components:**
1. **Compute Resources**
   - Application servers
   - Background workers
   - Load balancers

2. **Data Layer**
   - Database instances
   - Cache layers
   - Message queues

3. **Security**
   - VPC configuration
   - Security groups
   - SSL certificates

**Scalability Plan:**
- Auto-scaling policies
- Performance thresholds
- Cost optimization

**Deployment Pipeline:**
- CI/CD configuration
- Testing stages
- Rollback procedures
EOF

# Testing Commands
cat > commands/testing/create-test-plan.md << 'EOF'
# Test Plan Creation Prompt

Create comprehensive test plan for {FEATURE_NAME} in Testudo Trade.

**Feature Details:**
- Component: {COMPONENT_NAME}
- User Stories: {USER_STORIES}
- Acceptance Criteria: {ACCEPTANCE_CRITERIA}

**Test Types:**
1. **Unit Tests**
   - Function-level testing
   - Mock dependencies
   - Edge case coverage

2. **Integration Tests**
   - API endpoint testing
   - Database interactions
   - External service integration

3. **End-to-End Tests**
   - User workflow testing
   - Cross-browser compatibility
   - Performance testing

**Risk-Specific Testing:**
- Order execution accuracy
- Risk calculation validation
- Real-time data processing
- Error scenario handling

**Success Criteria:**
- Coverage targets: {COVERAGE_TARGET}%
- Performance requirements
- Reliability metrics
EOF

# Documentation Commands
cat > commands/documentation/create-api-docs.md << 'EOF'
# API Documentation Prompt

Create comprehensive API documentation for {API_ENDPOINT} in Testudo Trade.

**Endpoint Details:**
- Method: {HTTP_METHOD}
- Path: {ENDPOINT_PATH}
- Purpose: {ENDPOINT_PURPOSE}

**Documentation Sections:**
1. **Overview**
   - Endpoint description
   - Use cases
   - Prerequisites

2. **Request Format**
   - Headers required
   - Parameters (path, query, body)
   - Authentication requirements

3. **Response Format**
   - Success responses
   - Error responses
   - Status codes

4. **Examples**
   - Sample requests
   - Sample responses
   - Code snippets ({PROGRAMMING_LANGUAGE})

**Trading-Specific:**
- Risk implications
- Exchange integration notes
- Real-time considerations
EOF

cat > commands/documentation/user-guide.md << 'EOF'
# User Guide Creation Prompt

Create user guide for {FEATURE_NAME} in Testudo Trade.

**Feature:** {FEATURE_NAME}
**User Type:** {USER_TYPE} (Beginner/Intermediate/Advanced)
**Use Case:** {PRIMARY_USE_CASE}

**Guide Structure:**
1. **Overview**
   - Feature purpose
   - Benefits
   - Prerequisites

2. **Step-by-Step Instructions**
   - Setup procedures
   - Configuration options
   - Usage examples

3. **Risk Management**
   - Safety guidelines
   - Best practices
   - Common mistakes

4. **Troubleshooting**
   - Common issues
   - Error messages
   - Support contacts

**Target Outcome:** {DESIRED_USER_OUTCOME}
EOF

# Security Commands
cat > commands/security/security-audit.md << 'EOF'
# Security Audit Prompt

Perform security audit for {COMPONENT_NAME} in Testudo Trade.

**Audit Scope:**
- Component: {COMPONENT_NAME}
- Risk Level: {RISK_LEVEL}
- Audit Type: {AUDIT_TYPE} (Code/Infrastructure/Process)

**Security Domains:**
1. **Authentication & Authorization**
   - User authentication mechanisms
   - API key management
   - Permission controls

2. **Data Protection**
   - Encryption at rest
   - Encryption in transit
   - PII handling

3. **Input Validation**
   - Parameter validation
   - SQL injection prevention
   - XSS protection

**Crypto Trading Specific:**
- Exchange API security
- Financial data protection
- Trading operation integrity
- Risk management bypass prevention

**Threat Model:**
- Potential attack vectors
- Impact assessment
- Mitigation strategies
EOF

# Market Analysis Commands
cat > commands/market-analysis/backtest-strategy.md << 'EOF'
# Strategy Backtesting Prompt

Backtest trading strategy for {STRATEGY_NAME} in Testudo Trade.

**Strategy Details:**
- Strategy Name: {STRATEGY_NAME}
- Time Frame: {TIME_FRAME}
- Markets: {MARKETS_LIST}
- Risk Parameters: {RISK_PARAMETERS}

**Backtesting Setup:**
1. **Data Requirements**
   - Historical data period: {DATA_PERIOD}
   - Data frequency: {DATA_FREQUENCY}
   - Data sources: {DATA_SOURCES}

2. **Strategy Logic**
   - Entry conditions: {ENTRY_CONDITIONS}
   - Exit conditions: {EXIT_CONDITIONS}
   - Position sizing: {POSITION_SIZING_METHOD}
   - Risk management: {RISK_MANAGEMENT_RULES}

**Performance Metrics:**
- Total return: {TOTAL_RETURN}%
- Maximum drawdown: {MAX_DRAWDOWN}%
- Sharpe ratio: {SHARPE_RATIO}
- Win rate: {WIN_RATE}%

**Strategy Validation:**
- Out-of-sample testing results
- Walk-forward analysis
- Monte Carlo simulation
EOF

cat > commands/market-analysis/market-condition-analysis.md << 'EOF'
# Market Condition Analysis Prompt

Analyze current market conditions for {MARKET_NAME} trading in Testudo Trade.

**Market Context:**
- Market: {MARKET_NAME}
- Analysis Date: {ANALYSIS_DATE}
- Time Frame: {TIME_FRAME}

**Technical Analysis:**
1. **Trend Analysis**
   - Primary trend: {PRIMARY_TREND}
   - Secondary trend: {SECONDARY_TREND}
   - Support/resistance levels: {SUPPORT_RESISTANCE}

2. **Volatility Analysis**
   - Current volatility: {CURRENT_VOLATILITY}%
   - Historical volatility: {HISTORICAL_VOL_30D}%

**Risk Assessment:**
- Tail risk indicators: {TAIL_RISK_METRICS}
- Liquidity risk: {LIQUIDITY_RISK_LEVEL}
- Recommended position sizing: {POSITION_SIZING_ADVICE}

**Trading Recommendations:**
- Suitable strategies: {SUITABLE_STRATEGIES}
- Risk level: {RISK_LEVEL}
- Stop-loss placement: {STOP_LOSS_PLACEMENT}
EOF

cat > commands/market-analysis/risk-scenario-modeling.md << 'EOF'
# Risk Scenario Modeling Prompt

Model risk scenarios for {SCENARIO_NAME} in Testudo Trade risk management.

**Scenario Context:**
- Scenario Name: {SCENARIO_NAME}
- Probability: {SCENARIO_PROBABILITY}%
- Time Horizon: {TIME_HORIZON}

**Scenario Definition:**
- Price movement: {PRICE_MOVEMENT}%
- Volatility change: {VOLATILITY_CHANGE}%
- Liquidity impact: {LIQUIDITY_IMPACT}

**Portfolio Impact Analysis:**
- Total portfolio P&L: {PORTFOLIO_PNL}
- Maximum drawdown: {MAX_DRAWDOWN}
- Recovery time: {RECOVERY_TIME_ESTIMATE}

**Mitigation Strategies:**
- Position size limits: {POSITION_SIZE_LIMITS}
- Automatic position reduction: {AUTO_REDUCTION_RULES}
- Emergency procedures: {EMERGENCY_PROCEDURES}
EOF

# Productivity Commands
cat > commands/productivity/code-generation.md << 'EOF'
# Code Generation Prompt

Generate {CODE_TYPE} code for {COMPONENT_NAME} in Testudo Trade.

**Code Requirements:**
- Component: {COMPONENT_NAME}
- Language: {PROGRAMMING_LANGUAGE}
- Framework: {FRAMEWORK}
- Code Type: {CODE_TYPE}

**Functional Requirements:**
- Primary purpose: {PRIMARY_PURPOSE}
- Input parameters: {INPUT_PARAMETERS}
- Expected outputs: {EXPECTED_OUTPUTS}
- Business logic: {BUSINESS_LOGIC}

**Technical Specifications:**
- Design pattern: {DESIGN_PATTERN}
- Error handling: {ERROR_HANDLING_STRATEGY}
- Performance requirements: Response time <{RESPONSE_TIME}ms

**Crypto Trading Specific:**
- Exchange API integration: {EXCHANGE_INTEGRATION}
- Risk management hooks: {RISK_MANAGEMENT_HOOKS}
- Real-time data handling: {REALTIME_DATA_HANDLING}

**Generated Code Should Include:**
- Complete implementation
- Error handling
- Input validation
- Unit test template
- Documentation
EOF

cat > commands/productivity/automation-script.md << 'EOF'
# Automation Script Generation Prompt

Create automation script for {TASK_NAME} in Testudo Trade development workflow.

**Task Details:**
- Task Name: {TASK_NAME}
- Frequency: {TASK_FREQUENCY}
- Current Manual Process: {MANUAL_PROCESS_DESCRIPTION}
- Time Saved: {TIME_SAVINGS_ESTIMATE} hours/week

**Automation Requirements:**
- Primary function: {PRIMARY_FUNCTION}
- Input sources: {INPUT_SOURCES}
- Output destinations: {OUTPUT_DESTINATIONS}

**Error Handling:**
- Network failures: {NETWORK_FAILURE_HANDLING}
- API rate limits: {RATE_LIMIT_HANDLING}
- Retry logic: {RETRY_STRATEGY}

**Common Automation Tasks:**
- Database backup automation
- Log rotation and cleanup
- Performance metric collection
- Exchange API health checks
EOF

cat > commands/productivity/learning-plan.md << 'EOF'
# Learning Plan Creation Prompt

Create learning plan for {SKILL_AREA} to support Testudo Trade development.

**Learning Context:**
- Skill Area: {SKILL_AREA}
- Current Level: {CURRENT_SKILL_LEVEL}
- Target Level: {TARGET_SKILL_LEVEL}
- Timeline: {LEARNING_TIMELINE}

**Gap Analysis:**
- Strengths: {CURRENT_STRENGTHS}
- Weaknesses: {CURRENT_WEAKNESSES}
- Knowledge gaps: {KNOWLEDGE_GAPS}

**Learning Resources:**
- Books/eBooks: {BOOK_RECOMMENDATIONS}
- Online courses: {COURSE_RECOMMENDATIONS}
- Hands-on projects: {HANDS_ON_PROJECTS}

**Practice Projects:**
- Mini-projects for skill building
- Integration with Testudo Trade features
- Performance optimization exercises

**Common Learning Areas:**
- Blockchain fundamentals
- Exchange API integration
- Risk management algorithms
- Real-time data processing
- Financial mathematics
- Security best practices
EOF

# Create the master index file
cat > commands/index.md << 'EOF'
# Testudo Trade Commands Index

## 🎯 Quick Reference Guide

### By Development Phase

**🚀 MVP Development**
- [`validate-mvp-feature.md`](mvp/validate-mvp-feature.md) - Validate feature inclusion in MVP
- [`prioritize-backlog.md`](mvp/prioritize-backlog.md) - Prioritize development tasks
- [`mvp-architecture-decision.md`](mvp/mvp-architecture-decision.md) - Make architectural decisions

**🏗️ Core Development**
- [`architecture-review.md`](development/architecture-review.md) - Review system architecture
- [`code-review.md`](development/code-review.md) - Comprehensive code review
- [`debug-issue.md`](development/debug-issue.md) - Debug system issues

**🔄 Exchange Integration**
- [`integrate-exchange.md`](exchanges/integrate-exchange.md) - Integrate new exchange API
- [`test-exchange-api.md`](exchanges/test-exchange-api.md) - Test exchange integrations

**⚠️ Risk Management**
- [`design-risk-engine.md`](risk-management/design-risk-engine.md) - Design risk management system
- [`validate-risk-rules.md`](risk-management/validate-risk-rules.md) - Validate risk parameters

### By Problem Type

**🐛 Debugging & Issues**
```
Problem: System errors or unexpected behavior
Use: debug-issue.md
Input: Error logs, reproduction steps, system context
Output: Root cause analysis and fix recommendations
```

**⚡ Performance Problems**
```
Problem: Slow response times or high resource usage
Use: performance-analysis.md
Input: Performance metrics, system monitoring data
Output: Optimization recommendations and implementation plan
```

**💰 Cost Optimization**
```
Problem: High infrastructure costs
Use: cost-analysis.md
Input: Current spending breakdown, usage patterns
Output: Cost reduction strategies and implementation roadmap
```

**📈 Feature Development**
```
Problem: Building new functionality
Use: validate-mvp-feature.md → code-generation.md → create-test-plan.md
Input: Feature requirements, user stories
Output: Implementation plan and code templates
```

### By Urgency Level

**🚨 Critical (Use Immediately)**
- `debug-issue.md` - System down or critical bugs
- `security-audit.md` - Security incidents
- `setup-alerts.md` - Missing monitoring

**⚡ High Priority (Within 24 hours)**
- `performance-analysis.md` - Performance degradation
- `validate-risk-rules.md` - Risk management issues
- `test-exchange-api.md` - Exchange integration problems

**📅 Medium Priority (Within week)**
- `code-review.md` - Code quality improvements
- `optimize-api-calls.md` - Performance optimization
- `user-behavior-analysis.md` - User experience issues

**📋 Low Priority (Planned work)**
- `create-api-docs.md` - Documentation updates
- `learning-plan.md` - Skill development
- `backtest-strategy.md` - Strategy analysis

### Command Categories

#### 📁 `/development/` - Core Development
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `architecture-review.md` | System architecture review | Before major changes |
| `code-review.md` | Code quality assessment | Before merging code |
| `debug-issue.md` | Issue troubleshooting | When bugs occur |

#### 📁 `/exchanges/` - Exchange Integration
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `integrate-exchange.md` | Add new exchange | Expanding exchange support |
| `test-exchange-api.md` | Test integrations | After integration changes |

#### 📁 `/risk-management/` - Risk & Trading
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `design-risk-engine.md` | Risk system design | Building risk features |
| `validate-risk-rules.md` | Risk parameter validation | Before rule changes |

#### 📁 `/mvp/` - MVP Management
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `validate-mvp-feature.md` | Feature validation | Feature planning |
| `prioritize-backlog.md` | Task prioritization | Sprint planning |
| `mvp-architecture-decision.md` | Architecture decisions | Technical choices |

#### 📁 `/monitoring/` - Operations & Monitoring
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `setup-alerts.md` | Monitoring setup | System deployment |
| `performance-analysis.md` | Performance issues | Performance problems |
| `user-behavior-analysis.md` | User analytics | User experience optimization |

#### 📁 `/optimization/` - Performance & Cost
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `optimize-api-calls.md` | API optimization | High API usage |
| `database-optimization.md` | Database tuning | Database performance issues |
| `cost-analysis.md` | Cost optimization | Monthly cost review |

#### 📁 `/market-analysis/` - Trading & Strategy
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `backtest-strategy.md` | Strategy testing | Strategy development |
| `market-condition-analysis.md` | Market assessment | Trading environment changes |
| `risk-scenario-modeling.md` | Risk modeling | Risk assessment |

#### 📁 `/productivity/` - Developer Productivity
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `code-generation.md` | Code templates | Repetitive coding tasks |
| `automation-script.md` | Task automation | Manual process automation |
| `learning-plan.md` | Skill development | Knowledge gaps |

## 🔄 Common Workflows

### New Feature Development
1. `validate-mvp-feature.md` - Validate feature need
2. `mvp-architecture-decision.md` - Design approach
3. `code-generation.md` - Generate boilerplate
4. `create-test-plan.md` - Plan testing
5. `code-review.md` - Review implementation

### Performance Issue Investigation
1. `performance-analysis.md` - Analyze issue
2. `optimize-api-calls.md` - Optimize API usage
3. `database-optimization.md` - Tune database
4. `setup-alerts.md` - Prevent recurrence

### New Exchange Integration
1. `integrate-exchange.md` - Plan integration
2. `test-exchange-api.md` - Test implementation
3. `validate-risk-rules.md` - Validate risk handling

### Security Review
1. `security-audit.md` - Perform audit
2. `code-review.md` - Review security issues
3. `setup-alerts.md` - Monitor security metrics

## 🎮 Usage Tips

**Parameter Substitution:**
- Replace `{PARAMETER_NAME}` with actual values
- Use environment variables for sensitive data
- Keep parameter lists for reuse

**Customization:**
- Add project-specific requirements to prompts
- Modify success criteria based on your context
- Adapt timelines to your development velocity

**Documentation:**
- Save prompt results in corresponding `/docs/` folders
- Version control your customized prompts
- Build a knowledge base from prompt outputs

**Efficiency:**
- Create aliases for frequently used prompts
- Batch similar prompts for context efficiency
- Use prompts as templates for documentation
EOF

echo "📋 Created master index file"

# Create a README for the commands folder
cat > commands/README.md << 'EOF'
# Testudo Trade Commands

This folder contains parameterized prompts for AI-assisted development of Testudo Trade.

## Quick Start

1. **Copy a prompt template** from the appropriate subfolder
2. **Replace parameters** like `{COMPONENT_NAME}` with actual values
3. **Use with Claude Code** or any AI assistant
4. **Save results** in your project documentation

## Folder Structure

```
commands/
├── development/        # Core development workflows
├── exchanges/         # Exchange API integration
├── risk-management/   # Trading risk system design
├── infrastructure/    # Database and deployment
├── testing/          # Quality assurance
├── documentation/    # Technical writing
├── security/         # Security and compliance
├── mvp/             # MVP-specific decisions
├── monitoring/      # Operations and performance
├── optimization/    # Performance and cost tuning
├── market-analysis/ # Trading strategy development
├── productivity/    # Developer efficiency tools
└── index.md        # Master reference guide
```

## Example Usage

```bash
# Copy and customize a prompt
cp commands/mvp/validate-mvp-feature.md working-prompt.md

# Edit parameters
sed -i 's/{FEATURE_NAME}/Risk Dashboard/g' working-prompt.md
sed -i 's/{DEV_TIME_HOURS}/40/g' working-prompt.md

# Use with Claude Code
claude-code "Use this prompt: $(cat working-prompt.md)"
```

## Parameter Convention

- `{PARAMETER_NAME}` - Replace with actual values
- `{OPTIONAL_PARAMETER}` - Can be left blank if not applicable
- `{LIST_PARAMETER}` - Replace with comma-separated values

## Integration with Claude Code

These prompts are designed to work seamlessly with Claude Code for:
- Architecture decisions
- Code generation
- Testing strategies
- Performance optimization
- Security reviews

See `index.md` for complete usage guide.
EOF

echo "📖 Created README file"

# Create a quick setup verification script
cat > commands/verify-setup.sh << 'EOF'
#!/bin/bash

echo "🔍 Verifying Testudo Trade Commands setup..."

# Check folder structure
folders=(
    "development"
    "exchanges" 
    "risk-management"
    "infrastructure"
    "testing"
    "documentation"
    "security"
    "mvp"
    "monitoring"
    "optimization"
    "market-analysis"
    "productivity"
)

echo "Checking folders..."
for folder in "${folders[@]}"; do
    if [ -d "commands/$folder" ]; then
        echo "✅ $folder"
    else
        echo "❌ $folder - MISSING"
    fi
done

# Check key files
key_files=(
    "commands/index.md"
    "commands/README.md"
    "commands/mvp/validate-mvp-feature.md"
    "commands/development/architecture-review.md"
    "commands/exchanges/integrate-exchange.md"
    "commands/risk-management/design-risk-engine.md"
)

echo -e "\nChecking key files..."
for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $(basename $file)"
    else
        echo "❌ $(basename $file) - MISSING"
    fi
done

echo -e "\n🎉 Setup verification complete!"
echo "📖 Read commands/README.md for usage instructions"
echo "🎯 Start with commands/index.md for quick reference"
EOF

chmod +x commands/verify-setup.sh

echo "✨ Created verification script"

echo ""
echo "🎉 Successfully created Testudo Trade Commands structure!"
echo ""
echo "📁 Structure created:"
echo "   commands/"
echo "   ├── 12 specialized folders"
echo "   ├── 25+ prompt templates"
echo "   ├── index.md (master reference)"
echo "   ├── README.md (usage guide)"
echo "   └── verify-setup.sh (verification script)"
echo ""
echo "🚀 Next steps:"
echo "   1. Run: ./commands/verify-setup.sh"
echo "   2. Read: commands/README.md"
echo "   3. Start with: commands/mvp/validate-mvp-feature.md"
echo ""
echo "💡 For Claude Code integration:"
echo "   claude-code 'Use prompt: \$(cat commands/mvp/validate-mvp-feature.md)'"
echo ""
