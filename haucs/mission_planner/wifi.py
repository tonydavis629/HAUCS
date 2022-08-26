import os


class Finder:
    def __init__(self, *args, **kwargs):
        self.server_name = kwargs['server_name']
        self.password = kwargs['password']
        self.interface_name = kwargs['interface']
        self.main_dict = {}

    def run(self):
        command = """sudo iwlist wlp2s0 scan | grep -ioE 'ssid:"(.*{}.*)'"""
        result = os.popen(command.format(self.server_name))
        result = list(result)

        if "Device or resource busy" in result:
                return None
        else:
            ssid_list = [item.lstrip('SSID:').strip('"\n') for item in result]
            print("Successfully get ssids {}".format(str(ssid_list)))

        for name in ssid_list:
            try:
                result = self.connection(name)
            except Exception as exp:
                print("Couldn't connect to name : {}. {}".format(name, exp))
            else:
                if result:
                    print("Successfully connected to {}".format(name))

    def connection(self, name):
        cmd = "nmcli d wifi connect {} password {} iface {}".format(name,
            self.password,
            self.interface_name)
        try:
            if os.system(cmd) != 0: # This will run the command and check connection
                raise Exception()
        except:
            raise # Not Connected
        else:
            return True # Connected

if __name__ == "__main__":
    # Server_name is a case insensitive string, and/or regex pattern which demonstrates
    # the name of targeted WIFI device or a unique part of it.
    server_name = "SWP_BC06E4" #B27A5B
    password = "12345678"
    interface_name = "your_interface_name" # i. e wlp2s0  
    F = Finder(server_name=server_name,
               password=password,
               interface=interface_name)
    F.run()