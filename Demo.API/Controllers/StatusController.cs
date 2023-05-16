using Demo.API.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

using System;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DemoAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatusController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger _logger;
        public StatusController(IConfiguration config, ILogger<StatusController> logger)
        {
            _configuration = config;
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Get()
        {
            var version = _configuration["APPLICATION_VERSION"];
            //var deploymentRing = _configuration["DEPLOYMENT_RING"];
            var vm = new { Version = version };

            _logger.LogInformation($"Processing Status - Version: {version}");
            return new OkObjectResult(vm);
        }

        [HttpGet("full")]
        public IEnumerable<KeyValuePair<string, string>> GetFull()
        {
            var values = _configuration.AsEnumerable().Select(c => new KeyValuePair<string,string>(c.Key,c.Value));
            return values;
        }

        [HttpGet("kv")]
        public IActionResult GetKVSecret(string secretName)
        {
            string keyvaultURL = Environment.GetEnvironmentVariable("KEYVAULT_URL");
            SecretClient client = new SecretClient(new Uri(keyvaultURL),new DefaultAzureCredential());
            var keyvaultSecret = client.GetSecret(secretName).Value;
            return new OkObjectResult(keyvaultSecret);
        }

    }
}
