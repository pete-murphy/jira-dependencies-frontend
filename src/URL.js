exports.readEnv = () => ({
  urlPrefix: process.env.JIRA_URL_PREFIX,
  urlSuffix: process.env.JIRA_URL_SUFFIX,
});
