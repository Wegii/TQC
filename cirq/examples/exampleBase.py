class ExampleBase:
    """ Abstract class representing an example.

    The class represents a abstract example for defining and generating
    circuits.

    Attributes:
      circuit: Circuit object with all its moments.
    """
    circuit = None 

    def __init__(self):
        pass

    def generate_circuit(self) -> None:
        """ Generate the defined circuit.

        Longer description goes here.

        Args:
            <property>: Description

        Returns:
            Description

        Raises:
            <Error>: Description
        """
        raise NotImplementedError