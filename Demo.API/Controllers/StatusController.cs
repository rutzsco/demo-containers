using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

using System;
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

        public StatusController(IConfiguration config)
        {
            _configuration = config;
        }

        [HttpGet]
        public IActionResult Get()
        {
            var version = _configuration["APPLICATION_VERSION"];
            var vm = new { Version = version };
            return new OkObjectResult(vm);
        }

        [HttpGet("full")]
        public IEnumerable<KeyValuePair<string, string>> GetFull()
        {
            var values = _configuration.AsEnumerable().Select(c => new KeyValuePair<string,string>(c.Key,c.Value));
            return values;
        }
    }
}
