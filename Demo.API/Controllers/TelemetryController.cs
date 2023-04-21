using CloudNative.CloudEvents;
using Microsoft.AspNetCore.Mvc;

namespace Demo.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TelemetryController : ControllerBase
    {
        private readonly ILogger _logger;
       
        public TelemetryController(ILogger<TelemetryController> logger)
        {
            _logger = logger;
        }

        [HttpPost("telemetry-events")]
        public async Task<ActionResult> EventHubTelemetry(CloudEvent telemetryEvent)
        {
            try
            {
                // log entry
                _logger.LogInformation($"Processing event... Id: {telemetryEvent.Id} - Subject: {telemetryEvent.Subject} - Source: {telemetryEvent.Source}");
                return Ok();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while processing event.");
                return StatusCode(500);
            }
        }
    }
}
