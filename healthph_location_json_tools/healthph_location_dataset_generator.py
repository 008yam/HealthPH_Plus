"""
HealthPH+ Philippine Location JSON Generator

Purpose:
- Downloads PSGC location data from the public PSGC API mirror.
- Builds JSON files usable in Flutter cascading dropdowns and map/location filters.

Output folder:
assets/data/locations/

Generated files:
- regions.json
- provinces.json
- cities_municipalities.json
- barangays.json
- philippines_full.json
- barangays_by_region/<REGION_CODE>.json

Run:
python3 healthph_location_dataset_generator.py
"""

from __future__ import annotations

import json
import os
import urllib.request
from pathlib import Path
from typing import Any, Dict, List, Optional

BASE_URL = "https://psgc.gitlab.io/api"
OUTPUT_DIR = Path("assets/data/locations")

ENDPOINTS = {
    "regions": f"{BASE_URL}/regions.json",
    "provinces": f"{BASE_URL}/provinces.json",
    "cities_municipalities": f"{BASE_URL}/cities-municipalities.json",
    "barangays": f"{BASE_URL}/barangays.json",
}


def fetch_json(url: str) -> List[Dict[str, Any]]:
    print(f"Downloading: {url}")
    with urllib.request.urlopen(url, timeout=60) as response:
        raw = response.read().decode("utf-8")
    return json.loads(raw)


def write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
    print(f"Saved: {path}")


def first_present(record: Dict[str, Any], keys: List[str]) -> Optional[Any]:
    for key in keys:
        value = record.get(key)
        if value not in (None, ""):
            return value
    return None


def code_of(record: Dict[str, Any]) -> str:
    value = first_present(record, ["code", "psgcCode", "psgc_code", "psgc10DigitCode"])
    return str(value) if value is not None else ""


def name_of(record: Dict[str, Any]) -> str:
    value = first_present(record, ["name", "area_name", "areaName"])
    return str(value) if value is not None else ""


def region_code_of(record: Dict[str, Any]) -> str:
    value = first_present(record, ["regionCode", "region_code", "regCode"])
    if value:
        return str(value)

    code = code_of(record)
    if len(code) >= 2:
        return code[:2] + "0000000"
    return ""


def province_code_of(record: Dict[str, Any]) -> str:
    value = first_present(record, ["provinceCode", "province_code", "provCode"])
    if value:
        return str(value)

    code = code_of(record)
    if len(code) >= 5 and code[2:5] != "000":
        return code[:5] + "0000"
    return ""


def city_municipality_code_of(record: Dict[str, Any]) -> str:
    value = first_present(
        record,
        [
            "cityMunicipalityCode",
            "city_municipality_code",
            "municipalityCode",
            "municipality_code",
            "cityCode",
            "city_code",
        ],
    )
    if value:
        return str(value)

    code = code_of(record)
    if len(code) >= 6:
        return code[:6] + "000"
    return ""


def normalized_region(record: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "code": code_of(record),
        "name": name_of(record),
        "regionName": record.get("regionName", name_of(record)),
        "islandGroupCode": record.get("islandGroupCode"),
        "psgc10DigitCode": record.get("psgc10DigitCode"),
    }


def normalized_province(record: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "code": code_of(record),
        "name": name_of(record),
        "regionCode": region_code_of(record),
        "psgc10DigitCode": record.get("psgc10DigitCode"),
    }


def normalized_city(record: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "code": code_of(record),
        "name": name_of(record),
        "regionCode": region_code_of(record),
        "provinceCode": province_code_of(record),
        "isCity": bool(record.get("isCity", False)),
        "isMunicipality": bool(record.get("isMunicipality", False)),
        "psgc10DigitCode": record.get("psgc10DigitCode"),
    }


def normalized_barangay(record: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "code": code_of(record),
        "name": name_of(record),
        "regionCode": region_code_of(record),
        "provinceCode": province_code_of(record),
        "cityMunicipalityCode": city_municipality_code_of(record),
        "psgc10DigitCode": record.get("psgc10DigitCode"),
    }


def build_hierarchy(
    regions: List[Dict[str, Any]],
    provinces: List[Dict[str, Any]],
    cities: List[Dict[str, Any]],
    barangays: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    barangays_by_city: Dict[str, List[Dict[str, Any]]] = {}
    for barangay in barangays:
        barangays_by_city.setdefault(barangay["cityMunicipalityCode"], []).append(
            {
                "code": barangay["code"],
                "name": barangay["name"],
                "psgc10DigitCode": barangay.get("psgc10DigitCode"),
            }
        )

    cities_by_province: Dict[str, List[Dict[str, Any]]] = {}
    cities_by_region_without_province: Dict[str, List[Dict[str, Any]]] = {}

    for city in cities:
        city_object = {
            "code": city["code"],
            "name": city["name"],
            "isCity": city.get("isCity", False),
            "isMunicipality": city.get("isMunicipality", False),
            "psgc10DigitCode": city.get("psgc10DigitCode"),
            "barangays": barangays_by_city.get(city["code"], []),
        }

        province_code = city.get("provinceCode", "")
        if province_code:
            cities_by_province.setdefault(province_code, []).append(city_object)
        else:
            cities_by_region_without_province.setdefault(city["regionCode"], []).append(city_object)

    provinces_by_region: Dict[str, List[Dict[str, Any]]] = {}
    for province in provinces:
        province_object = {
            "code": province["code"],
            "name": province["name"],
            "psgc10DigitCode": province.get("psgc10DigitCode"),
            "citiesMunicipalities": cities_by_province.get(province["code"], []),
        }
        provinces_by_region.setdefault(province["regionCode"], []).append(province_object)

    full: List[Dict[str, Any]] = []
    for region in regions:
        region_provinces = provinces_by_region.get(region["code"], [])
        direct_cities = cities_by_region_without_province.get(region["code"], [])

        if direct_cities:
            virtual_province_name = "Metro Manila" if region["code"].startswith("13") else "Independent Cities / Municipalities"
            region_provinces = [
                {
                    "code": f"{region['code']}_NO_PROVINCE",
                    "name": virtual_province_name,
                    "isVirtual": True,
                    "citiesMunicipalities": direct_cities,
                }
            ] + region_provinces

        full.append(
            {
                "code": region["code"],
                "name": region["name"],
                "regionName": region.get("regionName", region["name"]),
                "islandGroupCode": region.get("islandGroupCode"),
                "psgc10DigitCode": region.get("psgc10DigitCode"),
                "provinces": region_provinces,
            }
        )

    return full


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    raw_regions = fetch_json(ENDPOINTS["regions"])
    raw_provinces = fetch_json(ENDPOINTS["provinces"])
    raw_cities = fetch_json(ENDPOINTS["cities_municipalities"])
    raw_barangays = fetch_json(ENDPOINTS["barangays"])

    regions = [normalized_region(item) for item in raw_regions]
    provinces = [normalized_province(item) for item in raw_provinces]
    cities = [normalized_city(item) for item in raw_cities]
    barangays = [normalized_barangay(item) for item in raw_barangays]

    full = build_hierarchy(regions, provinces, cities, barangays)

    write_json(OUTPUT_DIR / "regions.json", regions)
    write_json(OUTPUT_DIR / "provinces.json", provinces)
    write_json(OUTPUT_DIR / "cities_municipalities.json", cities)
    write_json(OUTPUT_DIR / "barangays.json", barangays)
    write_json(OUTPUT_DIR / "philippines_full.json", full)

    by_region_dir = OUTPUT_DIR / "barangays_by_region"
    by_region_dir.mkdir(parents=True, exist_ok=True)
    for region in regions:
        region_barangays = [b for b in barangays if b["regionCode"] == region["code"]]
        write_json(by_region_dir / f"{region['code']}.json", region_barangays)

    print("\nDONE")
    print(f"Regions: {len(regions)}")
    print(f"Provinces: {len(provinces)}")
    print(f"Cities/Municipalities: {len(cities)}")
    print(f"Barangays: {len(barangays)}")
    print(f"Output folder: {OUTPUT_DIR.resolve()}")


if __name__ == "__main__":
    main()
