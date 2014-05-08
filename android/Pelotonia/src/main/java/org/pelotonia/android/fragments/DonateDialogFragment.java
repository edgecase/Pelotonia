package org.pelotonia.android.fragments;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import org.pelotonia.android.R;
import org.pelotonia.android.objects.Rider;

public class DonateDialogFragment extends DialogFragment{
    Rider rider;

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        LayoutInflater inflater = getActivity().getLayoutInflater();

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        final View v = inflater.inflate(R.layout.donate_dialog, null);
        builder.setView(v)
                // Add action buttons
                .setPositiveButton(getString(R.string.send), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        EditText amount = (EditText) v.findViewById(R.id.donate_amount);
                        EditText email = (EditText) v.findViewById(R.id.email_address);
                        EditText name = (EditText) v.findViewById(R.id.email_name);
                        Intent emailIntent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts(
                                "mailto", email.getText().toString(), null));
                        emailIntent.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.email_subject));
                        String message = getString(R.string.email_message, name.getText().toString(), amount.getText().toString(), rider.name, rider.donateUrl, rider.name);
                        emailIntent.putExtra(Intent.EXTRA_TEXT, message);
                        startActivity(Intent.createChooser(emailIntent, getString(R.string.send_email)));
                    }
                })
                .setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        DonateDialogFragment.this.getDialog().cancel();
                    }
                });
        return builder.create();
    }

    public void setRider(Rider rider) {
        this.rider = rider;

    }
}
