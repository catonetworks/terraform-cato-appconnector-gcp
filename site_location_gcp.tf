locals {
  # Check if user provided site_location (any field is non-null)
  use_user_location = (
    var.site_location.city_name != null ||
    var.site_location.country_code != null ||
    var.site_location.state_code != null ||
    var.site_location.timezone != null
  )

  # Normalize region string (remove hyphens for lookup)
  region_key = lower(replace(var.region, "-", ""))

  # GCP Region to Location Mapping
  # Mapping GCP regions to their cities and countries for Cato site location
  # Note: Only US, AU, IN, BR state codes work - all others must be null
  region_to_site_location = {
    # Africa
    "africasouth1" = { city_name = "Johannesburg", country_code = "ZA", state_code = null, timezone = "Africa/Johannesburg" }

    # Asia Pacific - East Asia
    "asiaeast1" = { city_name = "Chang-hua", country_code = "TW", state_code = null, timezone = "Asia/Taipei" }
    "asiaeast2" = { city_name = "Hong Kong", country_code = "HK", state_code = null, timezone = "Asia/Hong_Kong" }

    # Asia Pacific - Northeast Asia
    "asianortheast1" = { city_name = "Tokyo", country_code = "JP", state_code = null, timezone = "Asia/Tokyo" }
    "asianortheast2" = { city_name = "Osaka", country_code = "JP", state_code = null, timezone = "Asia/Tokyo" }
    "asianortheast3" = { city_name = "Seoul", country_code = "KR", state_code = null, timezone = "Asia/Seoul" }

    # Asia Pacific - South Asia
    "asiasouth1" = { city_name = "Mumbai", country_code = "IN", state_code = "IN-MH", timezone = "Asia/Kolkata" }
    "asiasouth2" = { city_name = "Delhi", country_code = "IN", state_code = "IN-DL", timezone = "Asia/Kolkata" }

    # Asia Pacific - Southeast Asia
    "asiasoutheast1" = { city_name = "Singapore", country_code = "SG", state_code = null, timezone = "Asia/Singapore" }
    "asiasoutheast2" = { city_name = "Jakarta", country_code = "ID", state_code = null, timezone = "Asia/Jakarta" }

    # Australia
    "australiasoutheast1" = { city_name = "Sydney", country_code = "AU", state_code = "AU-NSW", timezone = "Australia/Sydney" }
    "australiasoutheast2" = { city_name = "Melbourne", country_code = "AU", state_code = "AU-VIC", timezone = "Australia/Melbourne" }

    # Europe - Central
    "europecentral2" = { city_name = "Warsaw", country_code = "PL", state_code = null, timezone = "Europe/Warsaw" }

    # Europe - North
    "europenorth1" = { city_name = "Helsinki", country_code = "FI", state_code = null, timezone = "Europe/Helsinki" }

    # Europe - Southwest
    "europesouthwest1" = { city_name = "Madrid", country_code = "ES", state_code = null, timezone = "Europe/Madrid" }

    # Europe - West
    "europewest1"  = { city_name = "Brussels", country_code = "BE", state_code = null, timezone = "Europe/Brussels" }
    "europewest2"  = { city_name = "London", country_code = "GB", state_code = null, timezone = "Europe/London" }
    "europewest3"  = { city_name = "Frankfurt am Main", country_code = "DE", state_code = null, timezone = "Europe/Berlin" }
    "europewest4"  = { city_name = "Brussels", country_code = "BE", state_code = null, timezone = "Europe/Brussels" }
    "europewest6"  = { city_name = "Zürich", country_code = "CH", state_code = null, timezone = "Europe/Zurich" }
    "europewest8"  = { city_name = "Milan", country_code = "IT", state_code = null, timezone = "Europe/Rome" }
    "europewest9"  = { city_name = "Paris", country_code = "FR", state_code = null, timezone = "Europe/Paris" }
    "europewest10" = { city_name = "Berlin", country_code = "DE", state_code = null, timezone = "Europe/Berlin" }
    "europewest12" = { city_name = "Turin", country_code = "IT", state_code = null, timezone = "Europe/Rome" }

    # Middle East
    "mecentral1" = { city_name = "Doha", country_code = "QA", state_code = null, timezone = "Asia/Qatar" }
    "mecentral2" = { city_name = "Dammam", country_code = "SA", state_code = null, timezone = "Asia/Riyadh" }
    "mewest1"    = { city_name = "Tel Aviv", country_code = "IL", state_code = null, timezone = "Asia/Jerusalem" }

    # North America - Canada
    "northamericanortheast1" = { city_name = "Montréal", country_code = "CA", state_code = null, timezone = "America/Toronto" }
    "northamericanortheast2" = { city_name = "Toronto", country_code = "CA", state_code = null, timezone = "America/Toronto" }

    # North America - Mexico
    "northamericasouth1" = { city_name = "Mexico city", country_code = "MX", state_code = null, timezone = "America/Mexico_City" }

    # South America
    "southamericaeast1" = { city_name = "São Paulo", country_code = "BR", state_code = "BR-SP", timezone = "UTC-3" }
    "southamericawest1" = { city_name = "Santiago", country_code = "CL", state_code = null, timezone = "America/Santiago" }

    # United States
    "uscentral1" = { city_name = "Council Bluffs", country_code = "US", state_code = "US-IA", timezone = "America/Chicago" }
    "useast1"    = { city_name = "Moncks Corner", country_code = "US", state_code = "US-SC", timezone = "America/New_York" }
    "useast4"    = { city_name = "Ashburn", country_code = "US", state_code = "US-VA", timezone = "America/New_York" }
    "useast5"    = { city_name = "Columbus", country_code = "US", state_code = "US-OH", timezone = "America/New_York" }
    "ussouth1"   = { city_name = "Dallas", country_code = "US", state_code = "US-TX", timezone = "America/Chicago" }
    "uswest1"    = { city_name = "The Dalles", country_code = "US", state_code = "US-OR", timezone = "America/Los_Angeles" }
    "uswest2"    = { city_name = "Los Angeles", country_code = "US", state_code = "US-CA", timezone = "America/Los_Angeles" }
    "uswest3"    = { city_name = "Salt Lake city", country_code = "US", state_code = "US-UT", timezone = "America/Denver" }
    "uswest4"    = { city_name = "Las Vegas", country_code = "US", state_code = "US-NV", timezone = "America/Los_Angeles" }
  }

  # Use user-provided location if any field is set, otherwise use hardcoded mapping
  cur_site_location = local.use_user_location ? var.site_location : local.region_to_site_location[local.region_key]
}

output "site_location" {
  description = "The resolved site location from GCP region mapping"
  value       = local.cur_site_location
}
