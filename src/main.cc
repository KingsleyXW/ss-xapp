
#include <thread>
#include <csignal>
#include <memory>

#include "mdclog/mdclog.h" // standard lib for logging 

#include "nexran.h" // importing the files and accesing the contents
#include "restserver.h"

static int signaled = -1;
static std::unique_ptr<nexran::App> app; // making a pointer to point to the app

void sigh(int signo) { // int signo is the trigger that triggered the handler
    signaled = signo;
    app->stop();
    exit(0);
}

int main(int argc,char **argv) {
    std::thread::id this_id; // declared the thread 
    std::unique_ptr<nexran::Config> config; //this pointer is created and destroyed, this is having a local scope.

    this_id = std::this_thread::get_id();

    mdclog_level_set(MDCLOG_DEBUG); // used of loging it is a standard lib 

    config = std::make_unique<nexran::Config>(); // assinging the unique pointer to the nexran::Config()
    if (!config || !config->parseArgv(argc,argv) || !config->parseEnv() || !config->validate()) { // the !config checks if the pointer is null pointer,
     // parenv is a method defined in nexran->Config() class(checks the if the pointer is pointing to the env variabeles silmilarly parseargv checks for the arguments and verification of all esential in configration of the  )
	mdclog_write(MDCLOG_ERR,"Failed to load config");
	config->usage(argv[0]);
	exit(1);
    }

    mdclog_write(MDCLOG_DEBUG,"Creating app and attaching to RMR"); // loging method 
    app = std::make_unique<nexran::App>(*config); //it is creating an instance, and assinging it to the app everything is a predefined cpp lib

    signal(SIGINT,sigh); // predefined methods sigint are user interupts sigint is sililar to ctrlc
    signal(SIGHUP,sigh); // sighup is terminal disconnect 
    signal(SIGTERM,sigh); // triggerd with commnads like kill

    mdclog_write(MDCLOG_DEBUG,"Starting app");
    app->start(); // startes the start method in the nexran.cc file

    while (true)

	sleep(1);
    exit(0);
}
