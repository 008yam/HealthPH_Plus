from pymongo import ReturnDocument

from app.core.config import settings


def next_readable_id(db, *, key: str, prefix: str, width: int = 6) -> str:
    counter = db[settings.mongo_id_counters_collection].find_one_and_update(
        {"_id": key},
        {"$inc": {"sequence": 1}},
        upsert=True,
        return_document=ReturnDocument.AFTER,
    )

    sequence = int(counter["sequence"])
    return f"{prefix}-{sequence:0{width}d}"