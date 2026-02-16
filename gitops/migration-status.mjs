import { $, YAML, fs, echo } from "zx";
import { promises as dns } from 'node:dns'

const dplplat01Ip = '20.86.109.250';
const dplplat02Ip = '130.226.25.93';

let sites = YAML.parse(await fs.readFileSync("../infrastructure/environments/dplplat01/sites.yaml", "utf-8")).sites;

let siteResults = await Promise.all(Object.entries(sites).map(async ([name, site]) => {
    // if (name !== 'kobenhavn') return;

    const status = { site: name };

    { // determine domains
        const domains = [site['primary-domain'], ...(site['secondary-domains'] || [])].filter(Boolean);
        const goDomains = domains.map(d => d.startsWith("www") ? `www.go${d.slice(3)}` : `go.${d}`);
        status.domains = domains.concat(goDomains);
    }

    { // determine dns status
        const result = await Promise.all(status.domains.map(async (domain) => ({ [domain]: (await dns.resolve(domain))[0] })));
        const domains = Object.assign({}, ...result);
        const ips = Object.values(domains);

        let dnsStatus = 'unknown';
        if (ips.every(ip => ip === dplplat01Ip)) {
            dnsStatus = 'not migrated';
        } else if (ips.every(ip => ip === dplplat02Ip)) {
            dnsStatus = 'migrated';
        } else {
            dnsStatus = 'partially migrated';
        }

        status.domains = {};
        Object.entries(domains).forEach(([domain, ip]) => status.domains[domain] = { ip: ip === dplplat01Ip ? `${dplplat01Ip} !!!` : ip });

        status.dns = dnsStatus;
    }

    { // determine dplplat01 status
        let dplplat01Status = 'unknown';
        const result = await Promise.all(Object.keys(status.domains).map(async (domain) => {
            try {
                const response = await $`curl -w "%{http_code}" -o /dev/null -s https://${dplplat01Ip} --insecure -H "Host: ${domain}"`;
                const statusCode = response.stdout.trim();
                if (["200", "301", "302", "308"].includes(statusCode)) {
                    status.domains[domain].dplplat01 = statusCode;
                    return `running`;
                }
                status.domains[domain].dplplat01 = `${statusCode} !!!`;
                return `not running`;
            } catch (error) {
                return `${domain} error`;
            }
        }));

        if (result.every(status => status === "running")) {
            dplplat01Status = 'running';
        } else if (result.every(status => status === "not running")) {
            dplplat01Status = 'not running';
        } else {
            dplplat01Status = 'partially running';
        }
        status.dplplat01 = dplplat01Status;
    }

    { // determine dplplat02 status
        let dplplat02Status = 'unknown';
        const result = await Promise.all(Object.keys(status.domains).map(async (domain) => {
            try {
                const response = await $`curl -w "%{http_code}" -o /dev/null -s https://${dplplat02Ip} --insecure -H "Host: ${domain}"`;
                const statusCode = response.stdout.trim();
                if (["200", "301", "302", "308"].includes(statusCode)) {
                    status.domains[domain].dplplat02 = statusCode;
                    return `running`;
                }
                status.domains[domain].dplplat02 = `${statusCode} !!!`;
                return `not running`;
            } catch (error) {
                return `${domain} error`;
            }
        }));

        if (result.every(status => status.endsWith("running"))) {
            dplplat02Status = 'running';
        } else if (result.every(status => status.endsWith("not running"))) {
            dplplat02Status = 'not running';
        } else {
            dplplat02Status = 'partially running';
        }
        status.dplplat02 = dplplat02Status;
    }

    { // actionable status
        const actions = [];

        // dplplat02 should return 30x or 200 for all domains
        if (status.dplplat02 !== "running") {
            actions.push("Investigate why the site is not fully running on dplplat02");
        }

        // if the site is migrated, but proxy is running then the proxy should be stopped
        if (status.dplplat01 === "running" && status.dns === "migrated") {
            actions.push("Stop the proxy on dplplat01");
        }

        // if the site is not migrated or partially migrated, then the proxy should still be running
        if (status.dns !== "migrated" && status.dplplat01 !== "running") {
            actions.push("Not migrated, proxy is required, but not fully running. Start the proxy on dplplat01 immediately!");
        }

        // if the dns is partially migrated, then let the site owner now that they should migrate fully to dplplat02
        if (status.dns === "partially migrated") {
            actions.push("Notify the site owner to migrate fully to dplplat02, or remove the non-migrated domains from the site configuration");
        }

        status.actions = actions;
    }

    return status;
}));

siteResults = siteResults.filter(Boolean);

// print results for fully migrated sites
const migratedSites = siteResults.filter(site => site.dns === "migrated");
echo(`Fully migrated sites: ${migratedSites.length}`);
echo(migratedSites.map(site => site.site).map(s => `- ${s}`).join("\n"), "\n");

// print results for non-migrated sites
const nonMigratedSites = siteResults.filter(site => site.dns === "not migrated");
echo(`Non-migrated sites: ${nonMigratedSites.length}`);
echo(nonMigratedSites.map(site => site.site).map(s => `- ${s}`).join("\n"), "\n");

// print results for partially migrated sites
const partiallyMigratedSites = siteResults.filter(site => site.dns === "partially migrated");
echo(`Partially migrated sites: ${partiallyMigratedSites.length}`);
echo(partiallyMigratedSites.map(site => site.site).map(s => `- ${s}`).join("\n"), "\n");

const actionableSites = siteResults.filter(site => site.actions.length > 0);
echo(`Actionable sites: ${actionableSites.length}`);
for (const site of actionableSites) {
    echo`
Site: ${site.site}
    DNS Status: ${site.dns}
    dplplat01 Status: ${site.dplplat01}
    dplplat02 Status: ${site.dplplat02}

    Actions:
${site.actions.map(action => `    - ${action}`).join("\n")}

    Resolved domains:`;
    console.table(site.domains)
    echo`
    Should resolve to dplplat02 IP: ${dplplat02Ip}
    `;
}

const nonActionableSites = siteResults.filter(site => site.actions.length === 0);
echo(`Non-actionable sites: ${nonActionableSites.length}`);
