from devices.device_KLM import Device_KLM
from examples.bellstate import Bellstate
from examples.circuitTest import CircuitTest
from ops.gates import *

import cirq
import sys

class Compiler:
    """ Compile the circuit into another language.

    This class translates, or compiles, a circuit into a lover level language
    for constructing a quantum circuit using the KLM protocol. The circuit to 
    compile is defined in the example property. The device property contains a
    cirq device, which allows for defining physical constraints on the circuit.

    If the circuit satisfies the defined constraints, it will be compiled to a
    lower-level language.

    Typical usage example: 
        compiler = Compiler(Device_KLM(), Bellstate())
        compiler = compiler.compile()

    Attributes:
        device: Cirq device defining constraints.
        example: Example object containing the circuit.
        file_output: File to write compiled circuit to.
        protocol: Physical protocol to implement to.

    Raises:
        ValueError: The circuit does not satisfy the constraints.
    """

    device = None
    example = None
    file_output = None
    __file_content = None
    protocol = None

    def __init__(self, device, example, file_output = 'quantum.qa', 
        protocol = Protocol.KLM):
        """ Init Compiler.

        Args:
          device: Cirq device.
          example: Example object containing the circuit.
          file_output: Name of the output file.
          protocol: Physical protocol for implementation.
        """

        self.device = device
        self.example = example
        self.file_output = file_output
        self.protocol = protocol

    def compile(self):
        """ Compile the cirquit.

        This functions will translate the cirq circuit representation of the
        defined circuit to a custom language.

        The following steps are performed:
          TODO
        """

        # Generate the actual circuit
        self.example.generate_circuit()

        # Check if circuit satisfies constraints
        try: 
            self.device.validate_circuit(self.example.circuit)
        except ValueError as error:
            print(error)

        print(self.example.circuit)

        # Perform simulations/operations if needed
        self.__simulation()
        self.__optimization()


        # Translate the generated circuit into a lower-level language.
        # Iterate over each moment and translate each of its gates.
        circuit = self.example.circuit

        cir = self.__initialize()
        cir_ops = ''
        for moment in circuit:
            for operation in moment.operations:
                qs = operation.qubits

                if str(operation).startswith('CNOT('):
                    cir_ops += Gate_CNOT(self.protocol).compile(qs[0], qs[1])
                elif str(operation).startswith('H('):
                    cir_ops += Gate_H(self.protocol).compile(qs[0])
                elif str(operation).startswith('X('):
                    cir_ops += Gate_X(self.protocol).compile(qs[0])
                else:
                    pass
                    #sys.exit('Gate not implemented!')

                cir_ops += '\n'

        cir += self.__align(cir_ops)
        cir += self.__finalize()

        # Perform optimization on the photonic circuit
        self.__optimizer()

        self.__export_circuit(cir)


        

    def __simulation(self):
        """ Perform simulations on the circuit. 

        The performed simulations are an integral part for choosing the correct 
        physical parts for constructing the circuit. The simulations could use gates
        with noise in order to determine which gates need to have a very high 
        fidelity.
        """
        pass

    def __optimization(self):
        """ Optimize the cirq circuit. """
        pass

    def __optimizer(self):
        """ Optimize the low-level circuit.

        The low-level circuit consisting of different parts can be optimized by
        e. g. merging two DCs to one single one.
        """
        pass

    def __stabilizer(self):
        """ Phase stabilizer.
        
        Add phase stabilizers to locations where local phase stability is needed.
        Phase instabilities are introduced due to different path lengths.
        """

    def __initialize(self) -> str:
        """ Initialize the output file.

        Initilize the file to write the compiled circuit to.
        """
        return '.text\n    _init\n\n    _init:\n        nop\n\n'

    def __finalize(self) -> str:
        """ Finalize the output file.

        Finalize the file to write the compuled circtuit to.
        """
        return '    _exit:\n        nop \n        ret\n'

    def __align(self, content) -> str:
        """ Align the content.

        Align each line in the content argument correctly. Add four spaces for
        alignment.

        Args:
            content: Content to correctly indent.
        """
        content = content.split('\n')
        nc = ''
        for line in content:
            nc += '    ' + line + '\n'

        return nc

    def __export_circuit(self, content=''):
        """ Write arbitrary content to a file.

        Args:
          content: Content of the file to write.
        """
        file = open(self.file_output, 'w')
        file.write(content)

        if not file.closed:
          file.close()



compiler = Compiler(Device_KLM(2), CircuitTest())
compiler = compiler.compile()
