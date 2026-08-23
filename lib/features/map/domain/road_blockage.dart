/// [LocalIncident.type] value used for a blocked-road report, so the map
/// layer can render it with a distinct icon. The blueprint's demo scenario
/// (section 15) models "blocked road" as an incident rather than a
/// separate road-network entity, and M03's schema follows that. M12 owns
/// the full incident-type vocabulary once it lands; this is the one value
/// M05 needs today.
const String roadBlockageIncidentType = 'road_blockage';
