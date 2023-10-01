from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional, Union


@dataclass
class Wire:
    label: Optional[str]
    input: Optional[Union[int, "Gate", "Wire"]] = None
    output: Optional[int] = None

    def resolve(self) -> int:
        if self.output is not None:
            return self.output
        elif isinstance(self.input, int):
            self.output = self.input
            return self.output
        elif self.input is None:
            raise ValueError(f"not connected: {self.label}")

        self.input = self.input.resolve()
        self.output = self.input
        return int(self.output)


class Operation(Enum):
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    LSHIFT = "LSHIFT"
    RSHIFT = "RSHIFT"


@dataclass
class Gate:
    a: Optional[Union[int, Wire]]
    op: Operation
    b: Optional[Union[int, Wire]]

    def resolve(self) -> int:
        if self.a is None and self.op not in [Operation.NOT]:
            raise ValueError("a should be assigned")
        elif isinstance(self.a, int):
            a = self.a
        else:
            a = self.a.resolve() if self.a is not None else -1

        if self.b is None:
            raise ValueError("b should be assigned")
        elif isinstance(self.b, int):
            b = self.b
        else:
            b = self.b.resolve()

        match self.op:
            case Operation.AND:
                if a is None:
                    raise ValueError("a should be assigned")
                return a & b
            case Operation.OR:
                if a is None:
                    raise ValueError("a should be assigned")
                return a | b
            case Operation.NOT:
                return b ^ 0xFFFF
            case Operation.LSHIFT:
                if a is None:
                    raise ValueError("a should be assigned")
                return a << b
            case Operation.RSHIFT:
                if a is None:
                    raise ValueError("a should be assigned")
                return a >> b
        raise ValueError("unhandled input")


class Solution:
    key = "07"

    def __init__(self, input: str):
        self.input = input

    def part_one(self, probe=False) -> Dict[str, int]:
        out: Dict[str, int] = {}
        for label, wire in self.parse().items():
            out[label] = wire.resolve()
        return out if not probe else {"a": out["a"]}

    def part_two(self, probe=False) -> Dict[str, int]:
        out: Dict[str, int] = {}
        wires = self.parse()
        if "a" in wires and "b" in wires:
            wires["b"].input = self.part_one()["a"]

        for label, wire in wires.items():
            out[label] = wire.resolve()
        return out if not probe else {"a": out["a"]}

    def parse(self) -> Dict[str, Wire]:
        wires: Dict[str, Wire] = {}

        for line in self.input.split("\n"):
            wire_input_label, wire_label = line.split(" -> ")
            if wire_label not in wires:
                wires[wire_label] = Wire(wire_label)
            wire = wires[wire_label]

            wire_input: Optional[Union[int, Gate, Wire]] = None
            match wire_input_label.split():
                case [a_label, op_name, b_label]:
                    op = Operation(op_name)

                    a: Union[int, Wire] = -1
                    if a_label.isnumeric():
                        a = int(a_label)
                    else:
                        if a_label not in wires:
                            wires[a_label] = Wire(a_label)
                        a = wires[a_label]

                    b: Union[int, Wire] = -1
                    if b_label.isnumeric():
                        # Handle *SHIFT
                        b = int(b_label)
                    else:
                        # Handle AND, OR, NOT
                        if b_label not in wires:
                            wires[b_label] = Wire(b_label)
                        b = wires[b_label]

                    wire_input = Gate(a, op, b)

                case [op_name, b_label]:
                    op = Operation(op_name)
                    if b_label not in wires:
                        wires[b_label] = Wire(b_label)
                    b = wires[b_label]
                    wire_input = Gate(None, op, b)

                case signal, *rest:
                    if len(rest):
                        raise ValueError(f"unhandled input: {line}")
                    if signal.isnumeric():
                        wire_input = int(signal)
                    else:
                        if signal not in wires:
                            wires[signal] = Wire(signal)
                        wire_input = wires[signal]

            if wire.input is not None:
                raise ValueError(f"already assigned input: {wire}")
            wire.input = wire_input

        return wires


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one(probe=True))
    print("Part 2:", Solution(input).part_two(probe=True))
