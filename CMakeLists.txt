cmake_minimum_required(VERSION 3.16)

project(VideoPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(AUTORCC_OPTIONS "src/qml.qrc")

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Core Gui QuickControls2 Multimedia)

qt_standard_project_setup()

qt_add_executable(appVideoPlayer
    main.cpp
)

qt_add_qml_module(appVideoPlayer
    URI VideoPlayer
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES qml.qrc
        QML_FILES RecentFilesPopup.qml
        QML_FILES
        QML_FILES ToastMessage.qml
        SOURCES recentfiles.h recentfiles.cpp
        SOURCES preferences.h preferences.cpp
        SOURCES
)

target_link_libraries(appVideoPlayer
    PRIVATE Qt6::Quick
    Qt6::Core
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Multimedia
)

include(GNUInstallDirs)
install(TARGETS appVideoPlayer
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
