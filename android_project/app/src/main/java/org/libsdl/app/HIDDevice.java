package org.libsdl.app;

import android.hardware.usb.UsbDevice;

interface HIDDevice
{
    public int getId();
    public int getVendorId();
    public int getProductId();
    public String getSerialNumber();
    public int getVersion();
    public String getManufacturerName();
    public String getProductName();
    public UsbDevice getDevice();
    public boolean open();
    public int writeReport(byte[] report, boolean feature);
    public boolean readReport(byte[] report, boolean feature);
    public void setFrozen(boolean frozen);
    public void close();
    public void shutdown();

    // From https://github.com/revery-ui/esy-sdl2/blob/master/android-project/app/src/main/java/org/libsdl/app/HIDDevice.java
    public int sendOutputReport(byte[] report);

    public int sendFeatureReport(byte[] report);

    boolean getFeatureReport(byte[] report);
}
