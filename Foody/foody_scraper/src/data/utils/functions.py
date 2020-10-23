def is_float(value: str) -> bool:
    try:
        float(value)
        return True
    except ValueError:
        return False
