#!/bin/bash
set -e

echo "Création des bases de données PostgreSQL..."
echo "Bases de données à créer:"
echo "  - strapi_cms"
echo "  - nocodb_app"
echo "  - n8n_workflows"
echo "  - metabase_analytics"
echo "  - serpbear_seo"
echo "  - brevo"
echo "  - google_data"
echo "  - social_network_data"
echo "  - marketing_ops"

# Fonction pour créer une base de données si elle n'existe pas
create_database_if_not_exists() {
    local db_name=$1
    echo "Création de la base de données: $db_name"
    
    # Vérifier si la base de données existe déjà
    db_exists=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname='$db_name'")
    
    if [ "$db_exists" != "1" ]; then
        echo "Création de la base de données $db_name..."
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "CREATE DATABASE \"$db_name\";"
        echo "Base de données $db_name créée avec succès"
    else
        echo "Base de données $db_name existe déjà"
    fi
    
    # Accorder les privilèges
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "GRANT ALL PRIVILEGES ON DATABASE \"$db_name\" TO \"$POSTGRES_USER\";"
}

# Création des bases de données pour chaque service
create_database_if_not_exists "strapi_cms"
create_database_if_not_exists "nocodb_app"
create_database_if_not_exists "n8n_workflows"
create_database_if_not_exists "metabase_analytics"
create_database_if_not_exists "serpbear_seo"
create_database_if_not_exists "brevo"
create_database_if_not_exists "google_data"
create_database_if_not_exists "social_network_data"
create_database_if_not_exists "marketing_ops"

echo "Toutes les bases de données ont été créées avec leurs privilèges!"

# Initialisation de la base Brevo pour les événements email
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "brevo" <<-EOSQL
    DROP TABLE IF EXISTS email_events;
    CREATE TABLE email_events (
        event_id SERIAL PRIMARY KEY,
        brevo_event_id VARCHAR(255),
        event_type VARCHAR(50) NOT NULL,
        event_timestamp TIMESTAMPTZ NOT NULL,
        recipient_email VARCHAR(255) NOT NULL,
        sender_email VARCHAR(255),
        subject TEXT,
        brevo_message_id VARCHAR(255),
        brevo_campaign_id BIGINT,
        brevo_list_ids INTEGER[],
        clicked_link TEXT,
        user_agent TEXT,
        ip_address VARCHAR(45),
        bounce_reason TEXT,
        tags TEXT[],
        metadata JSONB,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_email_events_event_type ON email_events(event_type);
    CREATE INDEX IF NOT EXISTS idx_email_events_recipient_email ON email_events(recipient_email);
    CREATE INDEX IF NOT EXISTS idx_email_events_event_timestamp ON email_events(event_timestamp);
    CREATE INDEX IF NOT EXISTS idx_email_events_brevo_message_id ON email_events(brevo_message_id);
    CREATE INDEX IF NOT EXISTS idx_email_events_brevo_campaign_id ON email_events(brevo_campaign_id);
EOSQL

# Initialisation de la base Google Data
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "google_data" <<-EOSQL
    -- Table Google Ads Performance
    DROP TABLE IF EXISTS google_ads_performance;
    CREATE TABLE google_ads_performance (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        account_id VARCHAR(255),
        account_name VARCHAR(255),
        campaign_id BIGINT,
        campaign_name TEXT,
        campaign_status VARCHAR(50),
        ad_group_id BIGINT,
        ad_group_name TEXT,
        ad_group_status VARCHAR(50),
        keyword_id BIGINT,
        keyword_text TEXT,
        keyword_match_type VARCHAR(50),
        impressions INTEGER,
        clicks INTEGER,
        cost_micros BIGINT,
        cost_euros NUMERIC(12, 2),
        conversions NUMERIC(10, 2),
        conversion_value NUMERIC(12, 2),
        ctr NUMERIC(7, 4),
        average_cpc_micros BIGINT,
        average_position NUMERIC(5, 2),
        device VARCHAR(50),
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (account_id, campaign_id, ad_group_id, keyword_id, report_date, device)
    );
    
    CREATE INDEX IF NOT EXISTS idx_ads_perf_report_date ON google_ads_performance(report_date);
    CREATE INDEX IF NOT EXISTS idx_ads_perf_campaign_id ON google_ads_performance(campaign_id);
    CREATE INDEX IF NOT EXISTS idx_ads_ad_group_id ON google_ads_performance(ad_group_id);
    
    -- Table Google Analytics Traffic
    DROP TABLE IF EXISTS google_analytics_traffic;
    CREATE TABLE google_analytics_traffic (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        view_id VARCHAR(255),
        property_id VARCHAR(255),
        source_medium VARCHAR(510),
        source VARCHAR(255),
        medium VARCHAR(255),
        campaign VARCHAR(255),
        landing_page TEXT,
        device_category VARCHAR(50),
        country VARCHAR(100),
        region VARCHAR(100),
        city VARCHAR(100),
        sessions INTEGER,
        users INTEGER,
        new_users INTEGER,
        bounces INTEGER,
        session_duration_seconds NUMERIC(12, 2),
        pageviews INTEGER,
        goal_completions INTEGER,
        transactions INTEGER,
        transaction_revenue NUMERIC(12, 2),
        engaged_sessions INTEGER,
        engagement_rate NUMERIC(7, 4),
        event_count INTEGER,
        conversions INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (property_id, view_id, report_date, source_medium, landing_page, device_category, country, region, city, campaign)
    );
    
    CREATE INDEX IF NOT EXISTS idx_analytics_perf_report_date ON google_analytics_traffic(report_date);
    CREATE INDEX IF NOT EXISTS idx_analytics_perf_source_medium ON google_analytics_traffic(source_medium);
    CREATE INDEX IF NOT EXISTS idx_analytics_perf_landing_page ON google_analytics_traffic(landing_page);
    
    -- Table Google Search Console Performance
    DROP TABLE IF EXISTS google_search_console_performance;
    CREATE TABLE google_search_console_performance (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        site_url TEXT NOT NULL,
        query TEXT,
        page TEXT,
        country VARCHAR(3),
        device VARCHAR(50),
        search_type VARCHAR(20),
        impressions INTEGER,
        clicks INTEGER,
        ctr NUMERIC(7, 4),
        position NUMERIC(7, 2),
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (site_url, query, page, report_date, device, country, search_type)
    );
    
    CREATE INDEX IF NOT EXISTS idx_gsc_perf_report_date ON google_search_console_performance(report_date);
    CREATE INDEX IF NOT EXISTS idx_gsc_perf_query ON google_search_console_performance(query);
    CREATE INDEX IF NOT EXISTS idx_gsc_perf_page ON google_search_console_performance(page);
EOSQL

# Initialisation de la base Social Network Data
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "social_network_data" <<-EOSQL
    -- Table Facebook Page Performance
    DROP TABLE IF EXISTS facebook_page_performance;
    CREATE TABLE facebook_page_performance (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        page_id VARCHAR(255) NOT NULL,
        page_name VARCHAR(255),
        page_impressions INTEGER,
        page_reach INTEGER,
        page_engaged_users INTEGER,
        page_total_followers INTEGER,
        page_new_followers INTEGER,
        page_video_views INTEGER,
        page_clicks_total INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (page_id, report_date)
    );
    
    CREATE INDEX IF NOT EXISTS idx_fb_page_perf_report_date ON facebook_page_performance(report_date);
    CREATE INDEX IF NOT EXISTS idx_fb_page_perf_page_id ON facebook_page_performance(page_id);
    
    -- Table Facebook Posts
    CREATE TABLE IF NOT EXISTS facebook_posts (
        post_record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        post_id VARCHAR(255) NOT NULL UNIQUE,
        page_id VARCHAR(255) NOT NULL,
        post_created_time TIMESTAMPTZ,
        post_type VARCHAR(50),
        post_message TEXT,
        post_link TEXT,
        post_impressions INTEGER,
        post_reach INTEGER,
        post_engaged_users INTEGER,
        post_reactions_total INTEGER,
        post_comments INTEGER,
        post_shares INTEGER,
        post_clicks INTEGER,
        post_video_views INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_fb_posts_post_id ON facebook_posts(post_id);
    CREATE INDEX IF NOT EXISTS idx_fb_posts_page_id ON facebook_posts(page_id);
    CREATE INDEX IF NOT EXISTS idx_fb_posts_created_time ON facebook_posts(post_created_time);
    
    -- Table Instagram Profile Performance
    DROP TABLE IF EXISTS instagram_profile_performance;
    CREATE TABLE instagram_profile_performance (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        profile_id VARCHAR(255) NOT NULL,
        profile_username VARCHAR(255),
        profile_impressions INTEGER,
        profile_reach INTEGER,
        profile_website_clicks INTEGER,
        profile_views INTEGER,
        profile_total_followers INTEGER,
        profile_new_followers INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (profile_id, report_date)
    );
    
    CREATE INDEX IF NOT EXISTS idx_ig_profile_perf_report_date ON instagram_profile_performance(report_date);
    CREATE INDEX IF NOT EXISTS idx_ig_profile_perf_profile_id ON instagram_profile_performance(profile_id);
    
    -- Table Instagram Media
    CREATE TABLE IF NOT EXISTS instagram_media (
        media_record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        media_id VARCHAR(255) NOT NULL UNIQUE,
        profile_id VARCHAR(255) NOT NULL,
        media_created_time TIMESTAMPTZ,
        media_type VARCHAR(50),
        media_caption TEXT,
        media_permalink TEXT,
        media_impressions INTEGER,
        media_reach INTEGER,
        media_engagement INTEGER,
        media_likes INTEGER,
        media_comments INTEGER,
        media_saves INTEGER,
        media_video_views INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_ig_media_media_id ON instagram_media(media_id);
    CREATE INDEX IF NOT EXISTS idx_ig_media_profile_id ON instagram_media(profile_id);
    CREATE INDEX IF NOT EXISTS idx_ig_media_created_time ON instagram_media(media_created_time);
    
    -- Table LinkedIn Page Performance
    DROP TABLE IF EXISTS linkedin_page_performance;
    CREATE TABLE linkedin_page_performance (
        record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        report_date DATE NOT NULL,
        organization_id VARCHAR(255) NOT NULL,
        page_name VARCHAR(255),
        page_impressions INTEGER,
        page_unique_impressions INTEGER,
        page_clicks INTEGER,
        page_reactions INTEGER,
        page_comments INTEGER,
        page_shares INTEGER,
        page_engagement_rate NUMERIC(7, 4),
        page_total_followers INTEGER,
        page_new_followers INTEGER,
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, report_date)
    );
    
    CREATE INDEX IF NOT EXISTS idx_li_page_perf_report_date ON linkedin_page_performance(report_date);
    CREATE INDEX IF NOT EXISTS idx_li_page_perf_org_id ON linkedin_page_performance(organization_id);
    
    -- Table LinkedIn Updates
    CREATE TABLE IF NOT EXISTS linkedin_updates (
        update_record_id SERIAL PRIMARY KEY,
        fetch_date DATE NOT NULL,
        update_urn_id VARCHAR(255) NOT NULL UNIQUE,
        organization_id VARCHAR(255) NOT NULL,
        update_created_time TIMESTAMPTZ,
        update_text TEXT,
        update_impressions INTEGER,
        update_unique_impressions INTEGER,
        update_clicks INTEGER,
        update_reactions INTEGER,
        update_comments INTEGER,
        update_shares INTEGER,
        update_engagement_rate NUMERIC(7, 4),
        processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_li_updates_update_id ON linkedin_updates(update_urn_id);
    CREATE INDEX IF NOT EXISTS idx_li_updates_org_id ON linkedin_updates(organization_id);
    CREATE INDEX IF NOT EXISTS idx_li_updates_created_time ON linkedin_updates(update_created_time);
EOSQL

# Initialisation de la base Marketing Ops
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "marketing_ops" <<-EOSQL
    -- Table Website Content Monitor
    CREATE TABLE IF NOT EXISTS website_content_monitor (
        monitor_id SERIAL PRIMARY KEY,
        fetch_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        url_checked TEXT NOT NULL,
        http_status_code INTEGER,
        extracted_title TEXT,
        extracted_url TEXT UNIQUE,
        extracted_date DATE,
        is_available BOOLEAN
    );
    CREATE INDEX IF NOT EXISTS idx_content_monitor_fetch_time ON website_content_monitor(fetch_timestamp);
    
    -- Table Content Suggestions IA
    CREATE TABLE IF NOT EXISTS content_suggestions (
        suggestion_id SERIAL PRIMARY KEY,
        date_suggestion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        titre_suggere TEXT NOT NULL,
        description_pertinence TEXT,
        target_keywords TEXT[],
        ai_model_used VARCHAR(100),
        confidence_score NUMERIC(3,2),
        status VARCHAR(50) DEFAULT 'suggéré'
    );
    
    -- Table Social Post Drafts
    CREATE TABLE IF NOT EXISTS social_post_drafts (
        draft_id SERIAL PRIMARY KEY,
        date_creation TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        article_lien TEXT,
        platform VARCHAR(50) NOT NULL,
        draft_text TEXT NOT NULL,
        hashtags TEXT[],
        mentions TEXT[],
        scheduled_for TIMESTAMPTZ,
        status VARCHAR(50) DEFAULT 'brouillon'
    );
    CREATE INDEX IF NOT EXISTS idx_drafts_platform ON social_post_drafts(platform);
    CREATE INDEX IF NOT EXISTS idx_drafts_status ON social_post_drafts(status);
    
    -- Table Competitor Mentions
    CREATE TABLE IF NOT EXISTS competitor_mentions (
        mention_id SERIAL PRIMARY KEY,
        fetch_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        competitor_name VARCHAR(255) NOT NULL,
        mention_title TEXT,
        mention_url TEXT UNIQUE,
        source_url TEXT,
        publication_date TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS idx_mentions_competitor ON competitor_mentions(competitor_name);
    CREATE INDEX IF NOT EXISTS idx_mentions_pub_date ON competitor_mentions(publication_date);
    
    -- Table Competitor Content
    CREATE TABLE IF NOT EXISTS competitor_content (
        content_id SERIAL PRIMARY KEY,
        fetch_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        competitor_name VARCHAR(255) NOT NULL,
        content_title TEXT,
        content_url TEXT UNIQUE,
        publication_date TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS idx_content_competitor ON competitor_content(competitor_name);
    CREATE INDEX IF NOT EXISTS idx_content_pub_date ON competitor_content(publication_date);
    
    -- Table Competitor Page Watch
    CREATE TABLE IF NOT EXISTS competitor_page_watch (
        watch_id SERIAL PRIMARY KEY,
        competitor_name VARCHAR(255) NOT NULL,
        page_url TEXT NOT NULL,
        css_selector TEXT NOT NULL,
        last_checked TIMESTAMPTZ,
        last_content_hash VARCHAR(64),
        last_content_preview TEXT,
        UNIQUE (page_url, css_selector)
    );
    
    -- Table SERP Rankings
    CREATE TABLE IF NOT EXISTS serp_rankings (
        ranking_id SERIAL PRIMARY KEY,
        fetch_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        report_date DATE NOT NULL,
        domain VARCHAR(255) NOT NULL,
        keyword TEXT NOT NULL,
        rank INTEGER,
        url TEXT,
        device VARCHAR(50),
        location VARCHAR(100),
        tags TEXT[],
        serpbear_check_id VARCHAR(255),
        change_from_previous INTEGER DEFAULT 0,
        UNIQUE (domain, keyword, report_date, device, location)
    );
    CREATE INDEX IF NOT EXISTS idx_serp_rank_report_date ON serp_rankings(report_date);
    CREATE INDEX IF NOT EXISTS idx_serp_rank_keyword ON serp_rankings(keyword);
    CREATE INDEX IF NOT EXISTS idx_serp_rank_domain ON serp_rankings(domain);
    
    -- Table Leads Management
    CREATE TABLE IF NOT EXISTS leads (
        lead_id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        first_name VARCHAR(255),
        last_name VARCHAR(255),
        company VARCHAR(255),
        phone VARCHAR(50),
        source VARCHAR(100),
        campaign VARCHAR(255),
        status VARCHAR(50) DEFAULT 'new',
        score INTEGER DEFAULT 0,
        tags TEXT[],
        notes TEXT,
        last_activity TIMESTAMPTZ,
        conversion_date TIMESTAMPTZ,
        lifetime_value NUMERIC(10,2) DEFAULT 0,
        custom_fields JSONB,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
    CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
    CREATE INDEX IF NOT EXISTS idx_leads_source ON leads(source);
    CREATE INDEX IF NOT EXISTS idx_leads_score ON leads(score);
    
    -- Table Lead Activities
    CREATE TABLE IF NOT EXISTS lead_activities (
        activity_id SERIAL PRIMARY KEY,
        lead_id INTEGER REFERENCES leads(lead_id) ON DELETE CASCADE,
        activity_type VARCHAR(100) NOT NULL,
        description TEXT,
        data JSONB,
        source VARCHAR(100),
        ip_address INET,
        user_agent TEXT,
        occurred_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    );
    CREATE INDEX IF NOT EXISTS idx_activities_lead ON lead_activities(lead_id);
    CREATE INDEX IF NOT EXISTS idx_activities_type ON lead_activities(activity_type);
    CREATE INDEX IF NOT EXISTS idx_activities_occurred ON lead_activities(occurred_at);
    
    -- Fonction utilitaire pour updated_at
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS \$\$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    \$\$ language 'plpgsql';
    
    -- Trigger pour leads
    CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EOSQL

echo "Base de données PostgreSQL initialisée avec succès!"
echo "Bases créées: $STRAPI_DB_NAME, $NOCODB_DB_NAME, $N8N_DB_NAME, $METABASE_DB_NAME, $SERPBEAR_DB_NAME, brevo, google_data, social_network_data, marketing_ops"
